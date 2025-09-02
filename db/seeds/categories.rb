if Category.count.zero?
    # if Company.count.zero?
    #   puts 'No companies found. Please seed companies first.'
    # else
    puts 'Seeding Categories'

    company_ids = Company.pluck(:id)
    categories_name = [
      'Контрольно измерительные приборы и автоматизация',
      'Центровка валов и выверка плоскостности',
      'Обслуживание и ремонт Газо-поршневых и дизельных двигателей',
      'Обслуживание и ремонт Компрессорного оборудования'
    ]

    categories_name.each do |name|
      category = Category.find_or_create_by!(name: name) do |cat|
        cat.description_ru = "
          Обеспечение оригинальными запасными частями.
          Проведение предварительной диагностики состояния оборудования
          для составления корректного списка необходимых запасных частей.

          Доставка запчастей до клиента (DDP).

          Продление межсервисных интервалов путем регулярной работы на объекте
          и следованию указаниям от завода –изготовителя.

          Опыт обслуживания компрессорных установок в РК и СНГ,
          а так же решение «нестандартных» ситуаций.",
          cat.description_kz = "
            Түпнұсқа қосалқы бөлшектермен қамтамасыз ету.
            Жабдықтың жағдайына алдын ала диагностика жүргізу
            қажетті қосалқы бөлшектердің дұрыс тізімін құрастыру.

            Тапсырыс берушіге қосалқы бөлшектерді жеткізу (DDP).

            Нысандағы тұрақты жұмыс арқылы қызмет көрсету аралықтарын ұзарту
            және өндірушінің нұсқауларын орындаңыз.

            Қазақстан Республикасында және ТМД елдерінде компрессорлық қондырғыларға қызмет көрсету тәжірибесі,
            сондай-ақ «стандартты емес» жағдайларды шешу.",
          cat.description_en = "
          Provision of original spare parts.
          Conducting preliminary diagnostics of the equipment condition
          to compile a correct list of necessary spare parts.

          Delivery of spare parts to the customer (DDP).

          Extending service intervals by regular work at the facility
          and following the instructions from the manufacturer.

          Experience in servicing compressor units in the Republic of Kazakhstan and the CIS,
          as well as resolving 'non-standard' situations.",
        cat.public_status = [ 0, 1 ].sample
      end

      # Если нужно привязать компании — раскомментируй
      # rand(1..5).times do
      #   company_id = company_ids.sample
      #   unless category.company_ids.include?(company_id)
      #     category.companies << Company.find(company_id)
      #   end
      # end
    end
  # end
end
