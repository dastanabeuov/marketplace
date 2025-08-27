class AddTranslationsToVacancies < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        Vacancy.create_translation_table!({
          name: :string,
          description: :text
        }, {
          migrate_data: true,
          remove_source_columns: true
        })
      end

      dir.down do
        Vacancy.drop_translation_table!(migrate_data: true)
      end
    end
  end
end
