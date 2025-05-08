FactoryBot.define do
  factory :product do
    name { "MyString" }
    price { "MyString" }
    producer { "MyString" }
    delivery_date { "MyString" }
    description { "MyText" }
    public_status { 1 }
    product_code { 1 }
  end
end
