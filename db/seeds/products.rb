if Product.count.zero?
  if Category.count.zero?
    puts 'No categories found. Please seed categories first.'
  elsif Company.count.zero?
    puts 'No companies found. Please seed companies first.'
  else
    puts 'Seeding Products'

    category_ids = Category.pluck(:id)
    company_ids = Company.pluck(:id)

    100.times do |i|
      product = Product.find_or_initialize_by(name: "Продукт #{i + 1}")
      product.description = "Описание продукта #{i + 1}. Содержит подробную информацию о товарах и услугах в данной категории.
        И нет сомнений, что стремящиеся вытеснить традиционное производство,
        нанотехнологии могут быть объективно рассмотрены соответствующими инстанциями.
        Приятно, граждане, наблюдать, как многие известные личности представляют
        собой не что иное, как квинтэссенцию победы маркетинга над разумом и
        должны быть обнародованы. Однозначно, представители современных
        социальных резервов освещают чрезвычайно интересные особенности
        картины в целом, однако конкретные выводы, разумеется, разоблачены."
      product.public_status ||= [ 0, 1 ].sample
      product.save!

      # Привязка к категориям
      rand(1..5).times do
        category_id = category_ids.sample
        product.categories << Category.find(category_id) unless product.category_ids.include?(category_id)
      end

      # Привязка к компаниям
      rand(1..3).times do
        company_id = company_ids.sample
        product.companies << Company.find(company_id) unless product.company_ids.include?(company_id)
      end

      # Установка производителя из одной из привязанных компаний
      # product.producer = Company.find(company_id).name

      # Прикрепить изображение, если не прикреплено
      unless product.image.attached?
        image_path = Rails.root.join("db", "seed_files", "product.jpg")
        if File.exist?(image_path)
          product.image.attach(
            io: File.open(image_path),
            filename: "product.jpg",
            content_type: "image/jpeg"
          )
        else
          puts "Image not found at #{image_path}"
        end
      end
    end
  end
end
