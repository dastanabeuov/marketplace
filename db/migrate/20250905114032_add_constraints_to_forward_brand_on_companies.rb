class AddConstraintsToForwardBrandOnCompanies < ActiveRecord::Migration[8.0]
  def change
    change_column_default :companies, :forward_brand, false
    change_column_null :companies, :forward_brand, false
  end
end
