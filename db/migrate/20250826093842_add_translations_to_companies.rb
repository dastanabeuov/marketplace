class AddTranslationsToCompanies < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        Company.create_translation_table!({
          name: :string,
          description: :text
        }, {
          migrate_data: true,
          remove_source_columns: true
        })
      end

      dir.down do
        Company.drop_translation_table!(migrate_data: true)
      end
    end
  end
end
