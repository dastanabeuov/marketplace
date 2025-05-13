class CreateProductCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :product_companies do |t|
      t.references :product, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_companies, [ :product_id, :company_id ], unique: true
  end
end
