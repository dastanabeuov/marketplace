class Product < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_many :product_companies, dependent: :destroy
  has_many :companies, through: :product_companies

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :public_status, presence: true
  # validates :categories, presence: true

  has_rich_text :description
  has_one_attached :image
  validates :image, attached_format: true
end
