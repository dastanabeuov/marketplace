class AddForwardBrandToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :forward_brand, :boolean, default: false, null: false
  end
end
