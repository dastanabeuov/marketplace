if Product.count.zero?
  if Category.count.zero?
    puts 'No categories found. Please seed categories first.'
  else
    puts 'Seeding Products'

    category_ids = Category.pluck(:id)

    1000.times do |i|
      product = Product.find_or_create_by!(name: "Продукт #{i + 1}")
      product.description ||= "Описание продукта #{i + 1}. Содержит подробную информацию о товарах и услугах в данной категории."
      product.public_status ||= [ 0, 1 ].sample
      product.save!

      rand(1..5).times do
        category_id = category_ids.sample

        unless product.category_ids.include?(category_id)
          product.categories << Category.find(category_id)
        end
      end
    end
  end
end
