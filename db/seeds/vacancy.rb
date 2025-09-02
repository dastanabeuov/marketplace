if Vacancy.count.zero?
  puts 'Seeding Vacancy'

  Vacancy.create!(
    name: "Главный специалист закупок",

    description_kz: "Вакансия сипаттамасы...
      Және күмән жоқ, дәстүрлі өндірісті ығыстыруға ұмтылған
      нанотехнологиялар тиісті органдар тарапынан объективті қарастырылуы мүмкін.
      Көптеген танымал тұлғалардың ақылға емес, маркетингтің жеңісі болып табылатынын
      байқау жағымды, азаматтар. Әрине, заманауи әлеуметтік резервтердің өкілдері
      жалпы көріністің өте қызықты ерекшеліктерін айқындайды, бірақ нақты қорытындылар
      әдеттегідей әшкереленген.",

    description_ru: "Описание вакансии...
      И нет сомнений, что стремящиеся вытеснить традиционное производство,
      нанотехнологии могут быть объективно рассмотрены соответствующими инстанциями.
      Приятно, граждане, наблюдать, как многие известные личности представляют
      собой не что иное, как квинтэссенцию победы маркетинга над разумом и
      должны быть обнародованы. Однозначно, представители современных
      социальных резервов освещают чрезвычайно интересные особенности
      картины в целом, однако конкретные выводы, разумеется, разоблачены.",

    description_en: "Job description...
      And there is no doubt that nanotechnologies, striving to displace traditional production,
      can be objectively considered by the relevant authorities.
      It is pleasant, citizens, to observe how many famous personalities represent
      nothing less than the quintessence of marketing’s triumph over reason,
      and should be made public. Definitely, representatives of modern social reserves
      highlight extremely interesting features of the overall picture,
      but specific conclusions, of course, have been exposed.",

    public_status: 1
  )
end
