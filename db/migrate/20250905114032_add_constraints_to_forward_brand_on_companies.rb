class AddConstraintsToForwardBrandOnCompanies < ActiveRecord::Migration[8.0]
  def up
    change_column_default :companies, :forward_brand, false
    change_column_null :companies, :forward_brand, false
  end

  def down
    change_column_null :companies, :forward_brand, true
    change_column_default :companies, :forward_brand, nil
  end
end
