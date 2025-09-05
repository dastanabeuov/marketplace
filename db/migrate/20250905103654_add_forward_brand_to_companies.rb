class AddForwardBrandToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :forward_brand, :boolean
  end
end
