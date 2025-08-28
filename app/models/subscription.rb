class Subscription < ApplicationRecord
  belongs_to :user, optional: true
  validates :email, presence: true, uniqueness: true
end
