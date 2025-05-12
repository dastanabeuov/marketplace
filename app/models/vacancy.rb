class Vacancy < ApplicationRecord
  validates :name, presence: true
end
