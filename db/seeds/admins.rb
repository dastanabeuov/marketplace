if AdminUser.count.zero?
  puts 'Seeding Admins'
  AdminUser.create!(
    email: 'admin@alatau-techno.kz',
    first_name: 'Человек',
    last_name: 'Паук',
    password: 'Admin2025!',
    password_confirmation: 'Admin2025!'
  )
end

# if User.count.zero?
#   user = User.new(email: 'john@doe.com', first_name: 'John', last_name: 'Doe', password: '123123', password_confirmation: '123123')

#   user.skip_confirmation!
#   user.save!
# end
