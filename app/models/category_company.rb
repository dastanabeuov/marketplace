class CategoryCompany < ApplicationRecord
  belongs_to :category
  belongs_to :company

  validates :category_id, uniqueness: { scope: :company_id }
end
