class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.references :user, foreign_key: true, null: true

      t.timestamps
    end
  end
end
