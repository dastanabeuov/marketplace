class Contact < ApplicationRecord
  translates :working_hours, :address
  accepts_nested_attributes_for :translations, allow_destroy: true

  # Валидации только для переводов
  translation_class.validates :working_hours, presence: true
  translation_class.validates :address, presence: true

  validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :map_iframe, presence: true

  has_one_attached :image
  validates :image, attached_format: true
end
