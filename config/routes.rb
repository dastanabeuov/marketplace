Rails.application.routes.draw do
  root to: "home#index"

  get "about", to: "home#about"
  get "contact", to: "home#contact"
  get "home/index"

  namespace :admin do
    root to: "main#index"

    resources :companies

    resources :categories do
      collection do
        get :search
      end
    end
  end

  scope :admin do
    devise_for :admin_users, controllers: { sessions: "admin/admins/sessions" }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
