# Демо-каталог для локальной разработки: 10 компаний и 10 товаров.
#
# Часть записей намеренно оставлена без картинки — на них видно, подставляется ли
# заглушка brand_empty.webp и держат ли карточки одинаковую высоту в сетке.
#
# Только development: на проде и в тестах эти данные не нужны, а db:seed там
# запускают на живой базе.
if Rails.env.development?
  DEMO_BRANDS = [
    "Ariel", "Waukesha", "Caterpillar", "Dresser-Rand", "Mycom",
    "Sullair", "Atlas Copco", "Howden", "Perkins", "Cummins"
  ].freeze

  # У каждой третьей записи картинки нет — проверяем заглушку
  def demo_image?(index) = (index % 3) != 2

  def attach_demo_image(record, file)
    return if record.image.attached?

    record.image.attach(
      io: File.open(Rails.root.join("db", "seed_files", file)),
      filename: file,
      content_type: "image/jpeg"
    )
  end

  if Company.count.zero?
    puts "Seeding demo companies"

    DEMO_BRANDS.each_with_index do |brand, i|
      company = Company.create!(
        name: brand,
        public_status: 1,
        forward_brand: i < 3,
        email: "sales@#{brand.parameterize}.example",
        phone: "+7 700 000-00-0#{i}",
        website: "https://#{brand.parameterize}.example"
      )

      attach_demo_image(company, "company.jpg") if demo_image?(i)
      company.save!
    end

    puts "  создано компаний: #{Company.count} (из них с картинкой: #{Company.joins(:image_attachment).count})"
  end

  if Product.count.zero? && Company.any? && Category.any?
    puts "Seeding demo products"

    company_ids  = Company.pluck(:id)
    category_ids = Category.pluck(:id)

    10.times do |i|
      product = Product.new(
        name: "Демо-товар #{i + 1}",
        price: "#{(i + 1) * 15_000} ₸",
        delivery_date: "#{(i % 4) + 1} нед.",
        producer: DEMO_BRANDS[i],
        product_code: 100_000 + i,
        public_status: 1
      )

      # Эти поля модель валидирует на присутствие для каждой локали
      I18n.available_locales.each do |locale|
        product.send("description_#{locale}=", "Описание демо-товара #{i + 1} для проверки вёрстки каталога.")
      end

      attach_demo_image(product, "product.jpg") if demo_image?(i)
      product.save!

      product.company_ids = company_ids.sample(rand(1..3))
      product.category_ids = category_ids.sample(rand(1..2))
    end

    puts "  создано товаров: #{Product.count} (из них с картинкой: #{Product.joins(:image_attachment).count})"
  end
end
