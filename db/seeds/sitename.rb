if Sitename.count.zero?
  puts 'Seeding Sitename'

  sitename = Sitename.new(
    name: "IZAK corp",
    description: "Описание компании..."
  )

  sitename.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "logo.jpeg")),
    filename: "logo.jpeg",
    content_type: "image/jpeg"
  )

  sitename.save!
end
