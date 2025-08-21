module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_by_name(query)
      return all if query.blank?

      if connection.adapter_name.downcase == "sqlite"
        where("LOWER(name) LIKE LOWER(?)", "%#{query}%")
      else
        where("name ILIKE ?", "%#{query}%")
      end
    end
  end
end
