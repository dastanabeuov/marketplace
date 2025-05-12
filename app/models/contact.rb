class Contact < ApplicationRecord
  validates :name, presence: true
  validates :working_hours, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :address, presence: true
  validates :map_iframe, presence: true
end
