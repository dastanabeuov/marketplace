if TermsOfUseSite.count.zero?
  puts 'Seeding Terms of use site'

  TermsOfUseSite.create!(
    name: "Условия использования",
    description: "Описание условия использования..."
  )
end
