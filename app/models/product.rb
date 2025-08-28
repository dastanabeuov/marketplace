class Product < ApplicationRecord
  include Searchable

  after_create :notify_subscribers

  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  has_many :product_companies, dependent: :destroy
  has_many :companies, through: :product_companies

  validates :public_status, presence: true

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
  validate :validate_descriptions

  private

  def validate_descriptions
    I18n.available_locales.each do |locale|
      field_name = "description_#{locale}"
      if self.send(field_name).blank? || self.send(field_name).body.blank?
        errors.add(field_name.to_sym, :blank, message: I18n.t("errors.messages.blank"))
      end
    end
  end


  def notify_subscribers
    Subscription.find_each do |subscription|
      ProductMailer.new_product(self, subscription).deliver_later
    end
  end
end
