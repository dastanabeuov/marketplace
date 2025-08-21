class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :price, null: false, default: "уточните у менеджера"
      t.string :producer
      t.string :delivery_date, null: false, default: "уточните у менеджера"
      t.text :description
      t.integer :public_status, null: false, default: 1
      t.integer :product_code

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :public_status
  end
end
