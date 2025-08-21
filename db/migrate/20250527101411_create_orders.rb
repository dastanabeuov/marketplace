class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :order_status, null: false, default: 0

      t.timestamps
    end
  end
end
