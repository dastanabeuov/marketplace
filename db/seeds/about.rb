if About.count.zero?
  puts 'Seeding About'

  about = About.new(
    name: "О нас",
    description: "Описание о нас (миссия, цели)..."
  )

  about.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "about.jpg")),
    filename: "about.jpg",
    content_type: "image/jpeg"
  )

  about.save!
end
