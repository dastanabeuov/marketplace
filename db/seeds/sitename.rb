if Sitename.count.zero?
  puts 'Seeding Sitename'

  Sitename.create!(
    name: "IZAK corp",
    description: "Описание компании..."
  )
end
