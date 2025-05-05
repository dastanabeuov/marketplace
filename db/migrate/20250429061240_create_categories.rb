class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :public_status, default: 1, null: false

      t.timestamps
    end
    add_index :categories, :name
    add_index :categories, :public_status
  end
end
