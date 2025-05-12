class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :working_hours, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :address, null: false
      t.text   :map_iframe, null: false

      t.timestamps
    end
  end
end
