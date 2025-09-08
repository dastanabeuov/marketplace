# lib/parsers/baumuller_brands_parser.rb
require "nokogiri"
require "open-uri"
require "uri"
require "net/http"
require "securerandom"
require "json"
require "fileutils"

module Parsers
  class BaumullerBrandsParser
    PROGRESS_FILE = "log/baumuller_progress.json"
    BASE_URL    = "https://baumuller.kz".freeze
    MAX_RETRIES = 3

    # маппинг локалей: у сайта kk, у нас kz
    LOCALES = {
      ru: "ru",
      en: "en",
      kz: "kk"
    }.freeze

    def initialize(target_companies)
      @target_companies = target_companies.map(&:downcase)
      @found_companies  = []
      @processed_brands = 0
      @total_products   = 0
    end

    def call
      progress = load_progress

      # Начинаем с последней обработанной страницы брендов + 1
      start_page = progress.dig("global", "last_brands_page") || 0
      page = start_page + 1

      log "Начинаем с страницы брендов: #{page}"

      loop do
        brands_url = "#{BASE_URL}/brands?page=#{page}"
        log "Загружаем страницу брендов: #{brands_url}"

        doc = fetch_page(brands_url)
        break unless doc

        brand_blocks = doc.css("div.card")
        if brand_blocks.empty?
          log "Больше нет страниц брендов. Завершаем работу."
          break
        end

        # Обрабатываем бренды на текущей странице
        processed_any = false
        brand_blocks.each do |block|
          if process_brand(block)
            processed_any = true
          end
        end

        # Сохраняем прогресс по страницам брендов
        save_global_progress(page)
        log "✅ Обработана страница брендов #{page}"

        page += 1
        sleep 1
      end

      save_log
    end

    private

    def process_brand(block)
      brand_name = block.at_css("div.card-body h5")&.text&.strip
      return false unless brand_name
      return false unless @target_companies.any? { |t| brand_name.downcase.include?(t) }

      log "→ Обрабатываем бренд: #{brand_name}"
      @found_companies << brand_name unless @found_companies.include?(brand_name)
      @processed_brands += 1

      company = Company.with_translations(I18n.locale).find_by(name: brand_name)

      unless company
        company = Company.new
        Globalize.with_locale(I18n.locale) { company.name = brand_name }
        company.save!
      end

      brand_url = absolute_url(block.at_css("a")&.[]("href"))
      image_url = absolute_url(block.at_css("a img")&.[]("src"))
      attach_image(company, image_url)

      parse_descriptions(company, brand_url)

      count = parse_products(company, brand_url)
      @total_products += count

      true # Возвращаем true, если бренд был обработан
    end

    def parse_descriptions(company, url)
      fallbacks = {
            ru: "ТОО 'Relicom-Parts' является поставщиком бренда #{company.name}.
        Мы осуществляем частичную и комплексную поставку запчастей и товаров
        бренда #{company.name} производственным предприятиям для всех типов оборудования.
        Наше сотрудничество гарантирует для Вас оптовые цены и интересные скидки.",

            kz: "«Relicom-Parts» ЖШС #{company.name} бренді жеткізушісі болып табылады.
        Біз барлық жабдық түрлеріне арналған қосалқы бөлшектер мен тауарларды
        жеке және кешенді жеткізуді жүзеге асырамыз.
        Біздің ынтымақтастығымыз Сізге көтерме бағалар мен тиімді жеңілдіктерді кепілдейді.",

            en: "LLP 'Relicom-Parts' is a supplier of the #{company.name} brand.
        We provide partial and comprehensive supply of spare parts and goods
        of the #{company.name} brand to manufacturing enterprises for all types of equipment.
        Our cooperation guarantees wholesale prices and attractive discounts for you."
          }

      LOCALES.each do |my_locale, remote_locale|
        localized_url = "#{url}?locale=#{remote_locale}"
        doc = fetch_page(localized_url)

        description = doc&.at_css(".brand-description")&.text&.strip
        value = description.presence || fallbacks[my_locale]

        company.public_send("description_#{my_locale}=", value)

        if description.blank?
          log "   ⚠ Нет описания для #{company.name} (#{my_locale}), установлена заглушка"
        else
          log "   ✅ Найдено описание для #{company.name} (#{my_locale})"
        end
      end

      company.save!
    end

    # def parse_descriptions(company, url)
    #   LOCALES.each do |my_locale, remote_locale|
    #     Globalize.with_locale(my_locale) do
    #       localized_url = "#{url}?locale=#{remote_locale}"
    #       doc = fetch_page(localized_url)

    #       description = doc&.at_css(".brand-description")&.text&.strip
    #       fallback    = "ТОО 'Relicom-Parts' является поставщиком бренда #{company.name}.
    #       Мы осуществляем частичную и комплексную поставку запчастей и товаров
    #       бренда Sick производственным предприятиям для всех типов оборудования.
    #       Наше сотрудничество гарантирует для Вас оптовые цены и интересные скидки."

    #       # присваиваем напрямую в rich_text поле
    #       company.public_send("description_#{my_locale}=", description.presence || fallback)

    #       if description.blank?
    #         log "   ⚠ Нет описания для #{company.name} (#{my_locale}), установлена заглушка"
    #       else
    #         log "   ✅ Найдено описание для #{company.name} (#{my_locale})"
    #       end
    #     end
    #   end

    #   company.save!
    # end

    # def parse_product_descriptions(product, url)
    #   LOCALES.each do |my_locale, remote_locale|
    #     Globalize.with_locale(my_locale) do
    #       localized_url = "#{url}?locale=#{remote_locale}"
    #       doc = fetch_page(localized_url)

    #       description = doc&.at_css(".product-description")&.text&.strip
    #       fallback    = "Доставка по всей территории Казахстана.
    #       По любым вопросам поставки Вы можете обращаться к нашим
    #       менеджерам по телефону или по электронной почте на сайте.
    #       Для оформления заявки на поставку оборудования и запчастей
    #       добавьте товар в корзину и оформите заказ."

    #       product.public_send("description_#{my_locale}=", description.presence || fallback)
    #     end
    #   end
    # end

    def parse_product_descriptions(product, url)
      fallbacks = {
            ru: "Доставка по всей территории Казахстана.
        По любым вопросам поставки Вы можете обращаться к нашим менеджерам
        по телефону или по электронной почте на сайте.
        Для оформления заявки на поставку оборудования и запчастей
        добавьте товар в корзину и оформите заказ.",
            kz: "Қазақстанның бүкіл аумағына жеткізу.
        Жеткізу мәселелері бойынша біздің менеджерлерге телефон немесе
        сайттағы электрондық пошта арқылы хабарласа аласыз.
        Жабдықтар мен қосалқы бөлшектерді жеткізуге өтінім беру үшін
        тауарды себетке қосып, тапсырыс беріңіз.",
            en: "Delivery throughout Kazakhstan.
        For any questions regarding delivery, you can contact our managers
        by phone or by email on the website.
        To place an order for equipment and spare parts,
        add the item to the cart and complete the checkout."
          }

      LOCALES.each do |my_locale, remote_locale|
        localized_url = "#{url}?locale=#{remote_locale}"
        doc = fetch_page(localized_url)

        description = doc&.at_css(".product-description")&.text&.strip
        value = description.presence || fallbacks[my_locale]

        product.public_send("description_#{my_locale}=", value)
      end

      product.save!
    end

    def parse_products(company, brand_url)
      progress = load_progress
      last_product_page = progress.dig("companies", company.name, "last_product_page") || 0

      # Начинаем с последней обработанной страницы продуктов + 1
      page = last_product_page + 1
      total = 0

      loop do
        product_page_url = page > 1 ? "#{brand_url}?page=#{page}" : brand_url
        doc = fetch_page(product_page_url)
        break unless doc

        product_cards = doc.css("div.card")
        if product_cards.empty?
          log "   ❌ У бренда #{company.name} больше нет продуктов на странице #{page}"
          break
        end

        log "   Найдено продуктов на странице #{page}: #{product_cards.size}"

        product_cards.each do |card|
          name = card.at_css("div.card-body a")&.text&.strip
          next unless name

          # Проверяем, существует ли уже продукт для этой компании
          # existing_relation = ProductCompany.joins(:product)
          #                                  .where(company: company, products: { name: name })
          #                                  .first
          existing_relation = ProductCompany.joins(product: :translations)
            .where(company: company, product_translations: { name: name, locale: I18n.locale })
            .first

          if existing_relation
            log "    Продукт уже существует: #{name} (пропускаем)"
            next
          end

          product = Product.with_translations(I18n.locale).find_by(name: name) || Product.new
          Globalize.with_locale(I18n.locale) { product.name = name }
          product.producer ||= company.name

          if product.new_record? || product.changed?
            parse_product_descriptions(product, product_page_url)
            product.save!
            log "    Сохранён продукт: #{product.name}"
          end

          image_url = absolute_url(card.at_css("a img")&.[]("src"))
          attach_image(product, image_url, company)

          ProductCompany.find_or_create_by!(product: product, company: company)
        end

        total += product_cards.size

        # Сохраняем прогресс по продуктам для этой компании
        save_company_progress(company.name, page)
        log "   ✅ Прогресс сохранён: #{company.name}, страница продуктов #{page}"

        page += 1
        sleep 1
      end

      total
    end

    # ---------- helpers ----------

    def load_progress
      return {} unless File.exist?(PROGRESS_FILE)
      JSON.parse(File.read(PROGRESS_FILE))
    rescue
      {}
    end

    def save_global_progress(brands_page)
      data = load_progress
      data["global"] ||= {}
      data["global"]["last_brands_page"] = brands_page
      data["global"]["last_updated"] = Time.current.iso8601
      File.open(PROGRESS_FILE, "w") { |f| f.write(JSON.pretty_generate(data)) }
    end

    def save_company_progress(company_name, product_page)
      data = load_progress
      data["companies"] ||= {}
      data["companies"][company_name] ||= {}
      data["companies"][company_name]["last_product_page"] = product_page
      data["companies"][company_name]["last_updated"] = Time.current.iso8601
      File.open(PROGRESS_FILE, "w") { |f| f.write(JSON.pretty_generate(data)) }
    end

    def fetch_page(url)
      retries ||= 0
      html = URI.open(url, "User-Agent" => "Mozilla/5.0", read_timeout: 20)
      Nokogiri::HTML(html)
    rescue => e
      if (retries += 1) <= MAX_RETRIES
        log "Ошибка загрузки (попытка #{retries}/#{MAX_RETRIES}): #{url}"
        sleep 2
        retry
      else
        log "❌ Ошибка при загрузке #{url}: #{e.message}"
        nil
      end
    end

    def attach_image(record, url, fallback_company = nil)
      return if record.respond_to?(:image) && record.image.attached?
      return unless url

      file = URI.open(url, "User-Agent" => "Mozilla/5.0")
      filename = File.basename(URI.parse(url).path.presence || "img_#{SecureRandom.hex(4)}.jpg")
      record.image.attach(io: file, filename: filename) if record.respond_to?(:image)
    rescue
      if fallback_company&.image&.attached? && record.respond_to?(:image)
        record.image.attach(fallback_company.image.blob)
      end
    end

    def absolute_url(path)
      return unless path
      path.start_with?("http") ? path : "#{BASE_URL}#{path}"
    end

    def save_log
      entry = {
        date: Date.today,
        brands: @processed_brands,
        products: @total_products,
        companies: @found_companies,
        status: "ok"
      }
      File.open("log/baumuller_parsing.log", "a") { |f| f.puts entry.to_json }
      log "Завершено: #{entry.inspect}"
    end

    def log(msg)
      puts "[Parser] #{msg}"
    end
  end
end
