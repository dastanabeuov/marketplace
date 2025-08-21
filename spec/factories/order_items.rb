FactoryBot.define do
  factory :order_item do
    order { nil }
    product { nil }
    quantity { 1 }
  end
end
