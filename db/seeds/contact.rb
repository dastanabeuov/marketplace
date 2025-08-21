if Contact.count.zero?
  puts 'Seeding Contact'

  contact = Contact.new(
    name: "ReliCom Parts",
    working_hours: "Пн-Пт 9:00-18:00, обед 13:00-14:00",
    email: "relicom-service@mail.ru",
    phone: "+7 705 634 2728",
    address: "050009, Алматы, Проспект Абая 143, Офис 508",
    map_iframe: '<iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3527.256805865845!2d76.89244894999999!3d43.23924975!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3883691659255a79%3A0x5c5bf060ccc1a26a!2z0JDQsdCw0Lkg0LTQsNKj0pPRi9C70YsgMTQzLCDQkNC70LzQsNGC0YsgMDUwMDAw!5e1!3m2!1skk!2skz!4v1755756166419!5m2!1skk!2skz"
                         width="400" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>'
  )

  contact.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "contact.jpg")),
    filename: "contact.jpg",
    content_type: "image/jpeg"
  )

  contact.save!
end
