if Mechanic.count.zero?
  puts 'Seeding Mechanic'

  mechanic = Mechanic.new(
    name: "Услуги по ремонту промышленного оборудования",

    description_kz: "Электрқозғалтқыштарды, арнайы электрқозғалтқыштарды (жоғары вольтты) айнымалы және тұрақты ток, генераторлар, тұрақты ток электрқозғалтқыштары, тартқыштар, кез келген күрделіліктегі жоғары вольтты трансформаторларды сапалы жөндеу жұмыстарын жүргіземіз.

Белгілі брендтер: Lenze, Siemens, Grundfos, ABB, Mitsubishi және басқа да көптеген өндірушілер.

Қажет болған жағдайда қалпына келтіруге жатпайтын қосалқы бөлшектерді жеткіземіз.

Әр клиентке жеке тәсіл және орындалған жұмысқа кепілдік береміз.",

    description_ru: "Осуществляем качественный ремонт электродвигателей, спецэлектродвигателей (высоковольтных) переменного и постоянного тока, генераторов, электродвигателей постоянного тока, тяговых, высоковольтных трансформаторов любой степени сложности.

Известные бренды: Lenze, Siemens, Grundfos, ABB, Mitsubishi и многих других производителей.

При необходимости осуществляем поставку запчастей не подлежащих восстановлению.

Индивидуальный подход к клиенту и гарантия на выполненную работу.",

    description_en: "We provide high-quality repair of electric motors, special electric motors (high-voltage) for AC and DC, generators, DC motors, traction, and high-voltage transformers of any complexity.

Famous brands: Lenze, Siemens, Grundfos, ABB, Mitsubishi, and many other manufacturers.

If necessary, we supply spare parts that cannot be restored.

An individual approach to each client and a guarantee for the completed work."
  )

  mechanic.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "mechanic.jpg")),
    filename: "mechanic.jpg",
    content_type: "image/jpeg"
  )

  mechanic.save!
end
