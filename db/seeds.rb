user = User.new(email: 'admin@example.com',
                password: 'Admin2025!',
                password_confirmation: 'Admin2025!',
                role: "admin",)

user.skip_confirmation!
user.save!
