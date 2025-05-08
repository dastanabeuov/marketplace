class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :price
      t.string :producer
      t.string :delivery_date
      t.text :description
      t.integer :public_status, default: 1, null: false
      t.integer :product_code

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :public_status
  end
end
