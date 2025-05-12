if PrivacyPolicy.count.zero?
  puts 'Seeding Privacy policy'

  PrivacyPolicy.create!(
    name: "Политика конфиденциальности",
    description: "Описание политика конфиденциальности..."
  )
end
