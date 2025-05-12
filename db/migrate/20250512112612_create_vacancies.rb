class CreateVacancies < ActiveRecord::Migration[8.0]
  def change
    create_table :vacancies do |t|
      t.string :name, null: false
      t.text :description
      t.integer :public_status, default: 1, null: false

      t.timestamps
    end
  end
end
