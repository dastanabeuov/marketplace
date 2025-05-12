if Vacancy.count.zero?
  puts 'Seeding Vacancy'

  Vacancy.create!(
    name: "Главный специалист закупок",
    description: "Описание вакансии...",
    public_status: 1
    )
end
