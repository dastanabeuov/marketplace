class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.text :description
      t.string :email
      t.string :phone
      t.string :website
      t.string :address
      t.integer :public_status, default: 1, null: false

      t.timestamps
    end
    add_index :companies, :name
    add_index :companies, :public_status
  end
end
