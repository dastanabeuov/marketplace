class User < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
end
