class Category < ApplicationRecord
  has_many :category_companies, dependent: :destroy
  has_many :companies, through: :category_companies

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :public_status, presence: true
end
