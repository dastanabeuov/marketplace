if Company.count.zero?
  puts 'Seeding Companies'
  100.times do |i|
    company = Company.create!(
      name: "Компания #{i + 1}",
      description: "Описание компании №#{i + 1}",
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
