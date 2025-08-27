if About.count.zero?
  puts 'Seeding About with translations for ru, kz, en'

  # Создаем новый экземпляр About
  about = About.new

  # Прикрепляем изображение (не зависит от языка)
  about.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "about.jpg")),
    filename: "about.jpg",
    content_type: "image/jpeg"
  )

  # Сохраняем запись сначала без валидаций, чтобы создать запись в базе
  about.save(validate: false)

  # Русский язык
  I18n.locale = :ru
  about.name = "О нас"
  # Для ActionText нужно использовать специальный метод
  about.update_attribute(:description_ru, "ТОО «Реликом сервис» объединяет профессионалов, связавших свою жизнь с компрессорным оборудованием и промышленными двигателями.

  Мы специализируемся на выполнении качественного технического обслуживания и ремонтов газо-поршневых, винтовых, центробежных, компрессорных установок с различными приводами (дизельные, газовые), а также генераторных установок газо-поршневых и дизельных, и обеспечении их надежной эксплуатации.
  Имеем богатый опыт обслуживания компрессорных установок в РК и СНГ, решения «нестандартных» ситуаций.

  Продление межсервисных интервалов путем регулярной работы на объектах заказчиков и выполнению требований завода-изготовителя.


  Основные принципы в работе:

  Квалифицированные специалисты.
  Продление срока службы оборудования.
  Профессиональные инструменты.
  Оптимизация рабочих процессов.
  Налаженная поставка запасных частей
  Передовые технологии диагностики оборудования.")

  # Казахский язык
  I18n.locale = :kz
  about.name = "Біз туралы"
  about.update_attribute(:description_ru, "ТОО «Реликом сервис» – компрессорлық жабдықтар мен өнеркәсіптік қозғалтқыштар саласына өмірін арнаған мамандарды біріктіретін компания.

  Біз газ-поршеньді, бұрандалы, орталықтан тепкіш компрессорлық қондырғыларды (дизельдік және газдық жетектермен), сондай-ақ газ-поршеньді және дизельдік генераторлық қондырғыларды сапалы техникалық қызмет көрсету мен жөндеуге, олардың сенімді жұмысын қамтамасыз етуге маманданамыз.

  Қазақстан мен ТМД елдерінде компрессорлық қондырғыларға қызмет көрсетуде, «стандарттан тыс» жағдайларды шешуде мол тәжірибеміз бар.

  Тапсырыс берушілердің нысандарында тұрақты жұмыс жүргізу және зауыт-өндірушінің талаптарын орындау арқылы аралық сервистік интервалдарды ұзартамыз.

  Жұмыстағы негізгі қағидаларымыз:

  Білікті мамандар.
  Жабдықтың қызмет ету мерзімін ұзарту.
  Кәсіби құралдар.
  Жұмыс процестерін оңтайландыру.
  Қосалқы бөлшектерді жүйелі жеткізу.
  Жабдықты диагностикалаудың заманауи технологиялары.")

  # Английский язык
  I18n.locale = :en
  about.name = "About Us"
  about.update_attribute(:description_en, 'LLP "Relicom Service" brings together professionals whose lives are dedicated to compressor equipment and industrial engines.

  We specialize in providing high-quality maintenance and repair of gas engine-driven, screw, centrifugal compressor units with various drives (diesel, gas), as well as gas and diesel generator sets, ensuring their reliable operation.

  We have extensive experience in servicing compressor units in Kazakhstan and the CIS, as well as solving “non-standard” situations.

  By carrying out regular work at customer sites and following the manufacturer’s requirements, we extend service intervals.

  Our core principles in work:

  Qualified specialists.
  Extending equipment lifetime.
  Professional tools.
  Optimization of work processes.
  Well-established spare parts supply.
  Advanced equipment diagnostics technologies.')

  puts "About created successfully with translations for ru, kk, en"
end
