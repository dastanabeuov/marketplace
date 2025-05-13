class Company < ApplicationRecord
  has_many :category_companies, dependent: :destroy
  has_many :categories, through: :category_companies

  has_many :product_companies, dependent: :destroy
  has_many :products, through: :product_companies

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
