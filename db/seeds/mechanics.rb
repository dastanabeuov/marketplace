if Mechanic.count.zero?
  puts 'Seeding Mechanic'

  mechanic = Mechanic.new(
    name: "Услуги по ремонту промышленного оборудования",
    description: "Осуществляем качественный ремонт электродвигателей, спецэлектродвигателей (высоковольтных) переменного и постоянного тока, генераторов, электродвигателей постоянного тока, тяговых, высоковольтных трансформаторов любой степени сложности

      Известные бренды: Lenze, Siemens, Grundfos, ABB, Mitsubishi и многих других производителей

      При необходимости осуществляем поставку запчастей не подлежащих восстановлению

      Индивидуальный подход к клиенту и гарантия на выполненную работу
    "
  )

  mechanic.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "mechanic.jpg")),
    filename: "mechanic.jpg",
    content_type: "image/jpeg"
  )

  mechanic.save!
end
