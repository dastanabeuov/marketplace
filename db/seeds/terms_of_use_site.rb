if TermsOfUseSite.count.zero?
  puts 'Seeding Terms of Use site'

  TermsOfUseSite.create!(
    name: "Terms of Use",

    description_kz: "Қолдану шарттары:
      Бұл сайтты пайдалану арқылы сіз төменде көрсетілген барлық шарттарды қабылдайсыз.
      Біздің қызметтерімізді пайдалану барысында қолданушылардың құқықтары мен
      міндеттері нақты көрсетілген. Компания технологиялық даму мен қауіпсіздік
      талаптарын қатаң сақтайды.",

    description_ru: "Условия использования:
      Используя данный сайт, вы соглашаетесь со всеми приведенными ниже условиями.
      В процессе использования наших сервисов права и обязанности пользователей
      четко определены. Компания строго соблюдает требования технологического
      развития и безопасности.",

    description_en: "Terms of Use:
      By using this website, you agree to all the terms and conditions listed below.
      The rights and responsibilities of users are clearly defined when using
      our services. The company strictly adheres to the requirements of
      technological development and security."
  )
end
