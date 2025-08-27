set :output, "log/whenever.log"
set :environment, ENV["RAILS_ENV"] || :development

every 1.day, at: "4:00 am" do
  rake "parse:daily_brands"
end
