# lib/parsers/baumuller_brands_parser.rb
require "nokogiri"
require "open-uri"
require "uri"
require "net/http"
require "securerandom"
require "json"

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
      page = 1
      loop do
        brands_url = "#{BASE_URL}/brands?page=#{page}"
        log "Загружаем страницу брендов: #{brands_url}"

        doc = fetch_page(brands_url)
        break unless doc

        brand_blocks = doc.css("div.card")
        break if brand_blocks.empty?

        brand_blocks.each { |block| process_brand(block) }

        page += 1
        sleep 1
      end

      save_log
    end

    private

    def process_brand(block)
      brand_name = block.at_css("div.card-body h5")&.text&.strip
      return unless brand_name
      return unless @target_companies.any? { |t| brand_name.downcase.include?(t) }

      log "→ Обрабатываем бренд: #{brand_name}"
      @found_companies << brand_name
      @processed_brands += 1

      company = Company.find_or_create_by!(name: brand_name)

      brand_url = absolute_url(block.at_css("a")&.[]("href"))
      image_url = absolute_url(block.at_css("a img")&.[]("src"))
      attach_image(company, image_url)

      parse_descriptions(company, brand_url)

      count = parse_products(company, brand_url)
      @total_products += count
    end

    def parse_descriptions(company, url)
      LOCALES.each do |my_locale, remote_locale|
        Globalize.with_locale(my_locale) do
          localized_url = "#{url}?locale=#{remote_locale}"
          doc = fetch_page(localized_url)

          description = doc&.at_css(".brand-description")&.text&.strip
          fallback    = "Описание отсутствует на #{my_locale.upcase}"

          # присваиваем напрямую в rich_text поле
          company.public_send("description_#{my_locale}=", description.presence || fallback)

          if description.blank?
            log "   ⚠ Нет описания для #{company.name} (#{my_locale}), установлена заглушка"
          else
            log "   ✅ Найдено описание для #{company.name} (#{my_locale})"
          end
        end
      end

      company.save!
    end

    def parse_product_descriptions(product, url)
      LOCALES.each do |my_locale, remote_locale|
        Globalize.with_locale(my_locale) do
          localized_url = "#{url}?locale=#{remote_locale}"
          doc = fetch_page(localized_url)

          description = doc&.at_css(".product-description")&.text&.strip
          fallback    = "Описание товара отсутствует на #{my_locale.upcase}"

          product.public_send("description_#{my_locale}=", description.presence || fallback)
        end
      end
    end

    def parse_products(company, url)
      progress = load_progress
      last_page = progress.dig(company.name, "last_page") || 0
      page = last_page + 1
      total = 0

      brand_page_url = page > 1 ? "#{url}?page=#{page}" : url
      doc = fetch_page(brand_page_url)
      return 0 unless doc

      product_cards = doc.css("div.card")
      if product_cards.empty?
        log "   ❌ У бренда #{company.name} страницы #{page} больше нет"
        return 0
      end

      log "   Найдено продуктов на странице #{page}: #{product_cards.size}"

      product_cards.each do |card|
        name = card.at_css("div.card-body a")&.text&.strip
        next unless name

        product = Product.find_or_initialize_by(name: name)
        product.producer ||= company.name

        if product.new_record? || product.changed?
          parse_product_descriptions(product, brand_page_url)
          product.save!
          log "    Сохранён продукт: #{product.name}"
        end

        image_url = absolute_url(card.at_css("a img")&.[]("src"))
        attach_image(product, image_url, company)

        ProductCompany.find_or_create_by!(product: product, company: company)
      end

      total += product_cards.size
      save_progress(company.name, page) # <--- запомнили текущую страницу

      log "   ✅ Прогресс сохранён: #{company.name}, страница #{page}"
      total
    end

    # ---------- helpers ----------

    def load_progress
      return {} unless File.exist?(PROGRESS_FILE)
      JSON.parse(File.read(PROGRESS_FILE))
    rescue
      {}
    end

    def save_progress(company_name, page)
      data = load_progress
      data[company_name] ||= {}
      data[company_name]["last_page"] = page
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
