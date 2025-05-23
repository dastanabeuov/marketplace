class Company < ApplicationRecord
  has_many :category_companies, dependent: :destroy
  has_many :categories, through: :category_companies

  has_many :product_companies, dependent: :destroy
  has_many :products, through: :product_companies

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_rich_text :description
  has_one_attached :image
  validates :image, attached_format: true
  # if has many images ore gallery_photos, you can use next code
  # has_many_attached :photos
  # validates :photos, attached_format: true
end
