namespace :parse do
  desc "Парсинг целевых брендов с baumuller.kz (одна страница в день)"
  task daily_brands: :environment do
    target_companies = [
      ## is not data Baumuller on 2024-06-19
      # "SKF"
      # "Ariel"
      # "Ajax Mycom",
      # "Mayekawa",
      # "Waukesha",
      # "Rexnord",
      # "Thomas Coupling",
      # "TB Woods",
      # "FW Murphy",
      # "Kenco",
      # "Ingersoll-Rand",
      # "Dresser-Rand",
      # "Air Cooler",
      # "Dodge bearings",

      ## downloadeded on 2024-06-20
      # "Caterpillar",
      # "Atlas Copco",
      # "Gea",
      # "Howden",
      # "Cummins"
    ]

    parser = Parsers::BaumullerBrandsParser.new(target_companies)
    parser.call
  end

  desc "Парсинг ВСЕХ брендов с baumuller.kz (с сохранением прогресса)"
  task all_brands: :environment do
    parser = Parsers::BaumullerBrandsParser.new([])
    parser.call
  end
end
