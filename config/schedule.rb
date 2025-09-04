# set :output, "log/whenever.log"
# set :environment, ENV["RAILS_ENV"] || :development

# every 1.day, at: "4:00 am" do
#   rake "parse:daily_brands"
# end

set :output, "/rails/log/whenever.log"
set :environment, "production"
set :chronic_options, hours24: true

every 1.day, at: "4:00" do
  rake "parse:daily_brands"
end
