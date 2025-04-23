Rails.application.routes.draw do
  root to: "home#index"

  get "about", to: "home#about"
  get "contact", to: "home#contact"
  get "home/index"

  namespace :admin do
    root to: "main#index"
    get "main/index"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
