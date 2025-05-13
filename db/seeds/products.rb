if Product.count.zero?
  if Category.count.zero?
    puts 'No categories found. Please seed categories first.'
  elsif Company.count.zero?
    puts 'No companies found. Please seed companies first.'
  else
    puts 'Seeding Products'

    category_ids = Category.pluck(:id)
    company_ids = Company.pluck(:id)

    1000.times do |i|
      product = Product.find_or_create_by!(name: "Продукт #{i + 1}")
      product.description ||= "Описание продукта #{i + 1}. Содержит подробную информацию о товарах и услугах в данной категории."
      product.public_status ||= [ 0, 1 ].sample
      product.save!

      # Привязка к категориям
      rand(1..5).times do
        category_id = category_ids.sample
        unless product.category_ids.include?(category_id)
          product.categories << Category.find(category_id)
        end
      end

      # Привязка к компаниям
      rand(1..3).times do
        company_id = company_ids.sample
        unless product.company_ids.include?(company_id)
          product.companies << Company.find(company_id)
        end
      end
    end
  end
end
