if Company.count.zero?
  puts 'Seeding Companies'
  1000.times do |i|
    Company.create!(
      name: "Компания #{i + 1}",
      description: "Описание компании №#{i + 1}",
      public_status: 1
    )
  end
end
