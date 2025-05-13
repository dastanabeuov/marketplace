class ProductCompany < ApplicationRecord
  belongs_to :product
  belongs_to :company

  validates :product_id, uniqueness: { scope: :company_id }
end
