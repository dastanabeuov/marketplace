class Category < ApplicationRecord
  has_many :category_companies, dependent: :destroy
  has_many :companies, through: :category_companies

  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :public_status, presence: true
end
