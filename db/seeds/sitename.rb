if Sitename.count.zero?
  puts 'Seeding Sitename'

  sitename = Sitename.new(
    name: "Relicom-parts",

    description_kz: "«Relicom сервис» мамандары компрессорлық жабдықтар мен өнеркәсіптік қозғалтқыштарға маманданған. Біз газ-поршеньді, бұрандалы, орталықтан тепкіш компрессорлық қондырғыларды және генераторларды сапалы техникалық қызмет көрсетуді және жөндеуді ұсынамыз.",

    description_ru: "ТОО «Реликом сервис» объединяет профессионалов, связавших свою жизнь с компрессорным оборудованием и промышленными двигателями. Мы специализируемся на выполнении качественного технического обслуживания и ремонтов газо-поршневых, винтовых, центробежных компрессорных установок, а также генераторных установок.",

    description_en: "Relicom Service LLP unites professionals dedicated to compressor equipment and industrial engines. We specialize in high-quality maintenance and repair of gas-piston, screw, centrifugal compressor units, as well as gas-piston and diesel generator sets."
  )

  # прикрепляем лого
  sitename.image.attach(
    io: File.open(Rails.root.join("db", "seed_files", "logo.png")),
    filename: "logo.png",
    content_type: "image/png"
  )

  sitename.save!
end
