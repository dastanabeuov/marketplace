class Mechanic < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true

  has_rich_text :description
  has_one_attached :image
  validates :image, attached_format: true
end
