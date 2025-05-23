if Category.count.zero?
  if Company.count.zero?
    puts 'No companies found. Please seed companies first.'
  else
    puts 'Seeding Categories'

    company_ids = Company.pluck(:id)

    100.times do |i|
      category = Category.find_or_create_by!(name: "Категория #{i + 1}") do |cat|
        cat.description = "Описание категории #{i + 1}. Содержит подробную информацию о товарах и услугах в данной категории."
        cat.public_status = [ 0, 1 ].sample
      end

      rand(1..5).times do
        company_id = company_ids.sample

        unless category.company_ids.include?(company_id)
          category.companies << Company.find(company_id)
        end
      end
    end
  end
end
