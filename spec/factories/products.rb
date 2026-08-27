FactoryBot.define do
  factory :product do
    name { "MyString" }
    price { "MyString" }
    producer { "MyString" }
    delivery_date { "MyString" }
    description { "MyText" }
    public_status { 1 }
    product_code { 1 }

    # rich text описания обязательны для каждой локали
    I18n.available_locales.each do |locale|
      add_attribute("description_#{locale}") { "MyText" }
    end
  end
end
