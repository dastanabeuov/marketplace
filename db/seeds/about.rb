if About.count.zero?
  puts 'Seeding About'

  About.create!(
    name: "О нас",
    description: "Описание о нас(миссия, цели)..."
  )
end
