class CreateTermsOfUseSites < ActiveRecord::Migration[8.0]
  def change
    create_table :terms_of_use_sites do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
