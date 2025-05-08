class Product < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :public_status, presence: true
  # validates :categories, presence: true
end
