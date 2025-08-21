require "nokogiri"
require "open-uri"
require "uri"
require "net/http"

namespace :parse do
  desc "Парсинг выбранных брендов и их продуктов с baumuller.kz"
  task selected_brands: :environment do
    # Список компаний для парсинга
    target_companies = [
      "Ariel", "Waukesha", "Caterpillar", "Dresser-Rand", "Mycom", 
      "Ajax", "Sullair", "Ekomak", "Atlas Copco", "Gea", 
      "Howden", "Perkins", "Cummins", "FG Wilson"
    ]
    
    # Преобразуем имена компаний в нижний регистр для регистронезависимого сравнения
    target_companies_downcase = target_companies.map(&:downcase)
    
    base_url = "https://baumuller.kz"
    page = 1
    total_brands = 0
    total_products = 0
    max_retries = 3
    found_companies = []

    puts "Начинаем парсинг выбранных брендов с сайта #{base_url}"
    puts "Целевые компании: #{target_companies.join(', ')}"

    loop do
      brands_url = "#{base_url}/brands?page=#{page}"
      puts "\nЗагружаем страницу брендов: #{brands_url}"

      begin
        html = URI.open(brands_url, read_timeout: 30)
        doc = Nokogiri::HTML(html)
      rescue OpenURI::HTTPError => e
        puts "Ошибка при загрузке страницы: #{e.message}"
        break
      rescue => e
        puts "Непредвиденная ошибка: #{e.message}"
        break
      end

      # Находим все карточки брендов на странице
      brand_blocks = doc.css("div.card")
      
      if brand_blocks.empty?
        puts "Страница #{page} не содержит брендов. Завершаем парсинг."
        break
      end

      puts "Найдено #{brand_blocks.size} брендов на странице #{page}"
      processed_on_page = 0

      brand_blocks.each_with_index do |brand_block, index|
        # Извлекаем название бренда
        brand_name = brand_block.at_css("div.card-body h5")&.text&.strip || 
                     brand_block.at_css("div.card-body")&.text&.strip
        
        next unless brand_name && !brand_name.empty?
        
        # Проверяем, входит ли бренд в список целевых компаний
        is_target = target_companies_downcase.any? { |target| brand_name.downcase.include?(target) }
        
        unless is_target
          puts "  Пропускаем бренд: #{brand_name} (не входит в целевой список)"
          next
        end
        
        found_companies << brand_name
        processed_on_page += 1
        puts "\n[#{total_brands + processed_on_page}] Обрабатываем бренд: #{brand_name}"

        # Получаем ссылку на страницу бренда
        brand_link = brand_block.at_css("a")&.attr("href")
        next unless brand_link
        
        brand_url = brand_link.start_with?("http") ? brand_link : "#{base_url}#{brand_link}"
        
        # Получаем изображение бренда
        image_tag = brand_block.at_css("a img")
        image_url = image_tag ? image_tag["src"] : nil
        
        if image_url
          image_url = image_url.start_with?("http") ? image_url : "#{base_url}#{image_url}"
        end

        # Создаем или находим компанию
        company = Company.find_or_initialize_by(name: brand_name)
        
        if company.new_record?
          company.save!
          puts "  Создана компания: #{company.name}"
        else
          puts "  Компания уже существует: #{company.name}"
        end

        # Прикрепляем изображение к компании, если оно есть и еще не прикреплено
        if image_url && !company.image.attached?
          retries = 0
          begin
            downloaded_image = URI.open(image_url, read_timeout: 30)
            filename = File.basename(URI.parse(image_url).path)
            filename = "#{SecureRandom.hex(8)}.jpg" if filename.empty? || filename == "/"
            
            company.image.attach(io: downloaded_image, filename: filename)
            puts "  Изображение прикреплено к компании: #{company.name}"
          rescue => e
            retries += 1
            if retries <= max_retries
              puts "  Ошибка загрузки изображения для #{company.name}: #{e.message}. Попытка #{retries}/#{max_retries}"
              sleep 1
              retry
            else
              puts "  Не удалось загрузить изображение для #{company.name} после #{max_retries} попыток: #{e.message}"
            end
          end
        end

        # Парсим продукты для этого бренда
        brand_products_count = parse_brand_products(base_url, brand_url, company, max_retries)
        total_products += brand_products_count
      end

      total_brands += processed_on_page
      
      # Если мы нашли все целевые компании, можно завершить парсинг
      if found_companies.size >= target_companies.size
        puts "\nВсе целевые компании найдены. Завершаем парсинг."
        break
      end
      
      page += 1
      
      # Проверяем наличие следующей страницы
      next_page_link = doc.at_css("ul.pagination li.page-item:last-child:not(.disabled) a")
      break unless next_page_link
      
      # Добавляем небольшую задержку между запросами страниц
      sleep 1
    end

    # Выводим список компаний, которые не были найдены
    not_found = target_companies.select { |company| !found_companies.any? { |found| found.downcase.include?(company.downcase) } }
    if not_found.any?
      puts "\nСледующие компании не были найдены на сайте:"
      not_found.each { |company| puts "- #{company}" }
    end

    puts "\nПарсинг завершен."
    puts "Всего обработано брендов: #{total_brands} из #{target_companies.size} целевых"
    puts "Всего обработано продуктов: #{total_products}"
  end
  
  # Метод для парсинга продуктов конкретного бренда
  def parse_brand_products(base_url, brand_url, company, max_retries)
    products_count = 0
    page = 1
    
    loop do
      brand_page_url = page > 1 ? "#{brand_url}?page=#{page}" : brand_url
      puts "  Загружаем страницу продуктов: #{brand_page_url}"
      
      begin
        html = URI.open(brand_page_url, read_timeout: 30)
        doc = Nokogiri::HTML(html)
      rescue OpenURI::HTTPError => e
        puts "  Ошибка при загрузке страницы продуктов: #{e.message}"
        break
      rescue => e
        puts "  Непредвиденная ошибка при загрузке страницы продуктов: #{e.message}"
        break
      end
      
      # Находим все карточки продуктов на странице
      product_cards = doc.css("div.card")
      
      if product_cards.empty?
        puts "  Страница #{page} не содержит продуктов. Завершаем парсинг для бренда #{company.name}."
        break
      end
      
      puts "  Найдено #{product_cards.size} продуктов на странице #{page}"
      
      product_cards.each do |card|
        # Извлекаем данные о продукте
        product_name = card.at_css("div.card-body a")&.text&.strip
        next unless product_name && !product_name.empty?
        
        # Получаем ссылку на детальную страницу продукта
        product_link = card.at_css("div.card-body a")&.attr("href")
        product_url = nil
        if product_link
          product_url = product_link.start_with?("http") ? product_link : "#{base_url}#{product_link}"
        end
        
        # Получаем изображение продукта
        image_tag = card.at_css("a img")
        image_url = image_tag ? image_tag["src"] : nil
        
        if image_url
          image_url = image_url.start_with?("http") ? image_url : "#{base_url}#{image_url}"
        end
        
        # Создаем или находим продукт
        product = Product.find_or_initialize_by(name: product_name)
        
        # Дополнительные поля, которые можно извлечь
        product.producer = company.name if product.producer.blank?
        
        # Если нужно получить дополнительные данные с детальной страницы продукта
        if product_url && (product.description.blank? || product.price.blank? || product.product_code.blank?)
          retries = 0
          begin
            product_html = URI.open(product_url, read_timeout: 30)
            product_doc = Nokogiri::HTML(product_html)
            
            # Извлекаем описание, если оно есть
            description = product_doc.at_css("div.description")&.text&.strip
            product.description = description if description && !description.empty?
            
            # Извлекаем цену, если она есть
            price = product_doc.at_css("div.price")&.text&.strip
            product.price = price if price && !price.empty?
            
            # Извлекаем код продукта, если он есть
            product_code_text = product_doc.at_css("div.product-code")&.text&.strip
            if product_code_text && product_code_text.match(/\d+/)
              product_code = product_code_text.match(/\d+/)[0]
              product.product_code = product_code.to_i if product_code.to_i > 0
            end
          rescue => e
            retries += 1
            if retries <= max_retries
              puts "    Ошибка при загрузке детальной страницы продукта: #{e.message}. Попытка #{retries}/#{max_retries}"
              sleep 1
              retry
            else
              puts "    Не удалось загрузить детальную страницу продукта после #{max_retries} попыток: #{e.message}"
            end
          end
        end
        
        if product.new_record?
          product.save!
          puts "    Создан продукт: #{product.name}"
        else
          product.save! if product.changed?
          puts "    Обновлен продукт: #{product.name}" if product.changed?
        end
        
        # Прикрепляем изображение к продукту, если оно есть и еще не прикреплено
        if image_url && !product.image.attached?
          retries = 0
          begin
            downloaded_image = URI.open(image_url, read_timeout: 30)
            filename = File.basename(URI.parse(image_url).path)
            filename = "#{SecureRandom.hex(8)}.jpg" if filename.empty? || filename == "/"
            
            product.image.attach(io: downloaded_image, filename: filename)
            puts "    Изображение прикреплено к продукту: #{product.name}"
          rescue => e
            retries += 1
            if retries <= max_retries
              puts "    Ошибка загрузки изображения для продукта #{product.name}: #{e.message}. Попытка #{retries}/#{max_retries}"
              sleep 1
              retry
            else
              puts "    Не удалось загрузить изображение для продукта #{product.name} после #{max_retries} попыток: #{e.message}"
            end
          end
        elsif company.image.attached? && !product.image.attached?
          # Если у продукта нет изображения, но есть у компании, используем его
          product.image.attach(company.image.blob)
          puts "    Изображение компании прикреплено к продукту: #{product.name}"
        end
        
        # Создаем связь между продуктом и компанией, если она еще не существует
        unless ProductCompany.exists?(product_id: product.id, company_id: company.id)
          ProductCompany.create!(product_id: product.id, company_id: company.id)
          puts "    Связь продукт-компания создана: #{product.name} - #{company.name}"
        end
        
        products_count += 1
      end
      
      page += 1
      
      # Проверяем наличие следующей страницы
      next_page_link = doc.at_css("ul.pagination li.page-item:last-child:not(.disabled) a")
      break unless next_page_link
      
      # Добавляем небольшую задержку между запросами страниц
      sleep 1
    end
    
    puts "  Всего обработано продуктов для бренда #{company.name}: #{products_count}"
    products_count
  end
end
