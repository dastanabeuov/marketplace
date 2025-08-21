class Order < ApplicationRecord
  # enum order_status: { pending: 0, issued: 1, rejected: 2 }

  ORDER_STATUSES = {
    0 => :pending,
    1 => :issued,
    2 => :rejected
  }.freeze

  belongs_to :user, optional: false
  has_many :order_items, inverse_of: :order, dependent: :destroy
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  validates :order_status, presence: true
  validates :user, presence: true
  has_many :order_items, dependent: :destroy
  validates :order_items, presence: true

  def order_status_name
    I18n.t("order_status.#{ORDER_STATUSES[order_status]}")
  end
end
