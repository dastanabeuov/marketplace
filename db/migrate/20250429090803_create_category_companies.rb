class CreateCategoryCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :category_companies do |t|
      t.references :category, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :category_companies, [ :category_id, :company_id ], unique: true
  end
end
