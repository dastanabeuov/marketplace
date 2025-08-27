class Company < ApplicationRecord
  include Searchable

  has_many :category_companies, dependent: :destroy
  has_many :categories, through: :category_companies

  has_many :product_companies, dependent: :destroy
  has_many :products, through: :product_companies

  has_one_attached :image
  validates :image, attached_format: true

  #----------------added translations----------------#
  translates :name
  accepts_nested_attributes_for :translations, allow_destroy: true

  # Валидации только для переводов
  translation_class.validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Создаем отдельные поля rich text для каждой локали
  I18n.available_locales.each do |locale|
    has_rich_text "description_#{locale}"
  end

  # Валидация для полей description по локалям
  # validate :validate_descriptions

  private

  def validate_descriptions
    I18n.available_locales.each do |locale|
      field_name = "description_#{locale}"
      if self.send(field_name).blank? || self.send(field_name).body.blank?
        errors.add(field_name.to_sym, :blank, message: I18n.t("errors.messages.blank"))
      end
    end
  end
end
