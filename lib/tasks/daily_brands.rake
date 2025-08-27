namespace :parse do
  desc "Парсинг целевых брендов с baumuller.kz (одна страница в день)"
  task daily_brands: :environment do
    target_companies = [
      "Caterpillar",
      "Atlas Copco",
      "Gea",
      "Howden",
      "Cummins"
    ]

    parser = Parsers::BaumullerBrandsParser.new(target_companies)
    parser.call
  end
end
