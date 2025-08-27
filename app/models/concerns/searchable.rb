module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_column(query, column = :name)
      return all if query.blank?

      if respond_to?(:translation_class)
        translation_table = translation_class.table_name
        joins(:translations).where("LOWER(#{translation_table}.#{column}) LIKE ?", "%#{query.downcase}%")
      else
        where("LOWER(#{table_name}.#{column}) LIKE ?", "%#{query.downcase}%")
      end
    end
  end
end
