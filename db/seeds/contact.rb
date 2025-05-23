if Contact.count.zero?
  puts 'Seeding Contact'

  contact = Contact.new(
    name: "Офис 1",
    working_hours: "Пн-Пт 9:00-18:00, обед 13:00-14:00",
    email: "info@alatau-techno.kz",
    phone: "8 (727) 226 94 10",
    address: "3 микрорайон 44-а",
    map_iframe: '<iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2823.9025146391414!2d76.84605237605491!3d43.226661671125605!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x38836929cb1eaee9%3A0xcb658efabdeda721!2z0LzQuNC60YDQvtGA0LDQudC-0L0gMyA0NCwg0JDQu9C80LDRgtGLIDA1MDA2Mg!5e1!3m2!1skk!2skz!4v1747043302415!5m2!1skk!2skz" width="400" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>'
  )

  contact.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "contact.jpg")),
    filename: "contact.jpg",
    content_type: "image/jpeg"
  )

  contact.save!
end
