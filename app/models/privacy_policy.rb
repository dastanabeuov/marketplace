class PrivacyPolicy < ApplicationRecord
  validates :name, presence: true

  has_rich_text :description
end
