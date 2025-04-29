class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.integer :public_status

      t.timestamps
    end
  end
end
