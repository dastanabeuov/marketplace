if Company.count.zero?
  puts 'Seeding Companies'

  brands = [ "Ariel", "Waukesha", "Caterpillar", "Dresser-Rand",
             "Mycom", "Ajax", "Sullair", "Ekomak", "Atlas Copco",
             "Gea", "Howden", "Perkins", "Cummins", "FG Wilson" ]

  brands.each do |b|
    company = Company.create!(
      name: b,
      description: "В базе Relicom-parts вне каталога более 200К. брендов оборудования
                    и комплектующих от ведущих и мировых производителей.

                    Если вы не нашли на сайте необходимый вам бренд или
                    категорию оборудования, свяжитесь с нами любым удобным
                    способом, и мы запросим товар напрямую у производителя.
                    А в случае отсутствия нужной позиции мы подберем для вас
                    полный аналог или предложим новое оборудование.",
      public_status: 1
    )

    company.image.attach(
      io: File.open(Rails.root.join("db", "seed_files", "company.jpg")),
      filename: "company.jpg",
      content_type: "image/jpeg"
    )

    company.save!
  end
end
