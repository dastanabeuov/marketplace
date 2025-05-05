FactoryBot.define do
  factory :admin_category, class: 'Admin::Category' do
    name { "MyString" }
    description { "MyText" }
    public_status { 1 }
    company { nil }
  end
end
