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
        get :search_company
      end
    end

    resources :products do
      collection do
        get :search_category
        get :search_company
      end
    end

    resource :sitename
    resource :privacy_policy
    resource :terms_of_use_site
    resource :contact
    resource :about
    resources :vacancies
  end

  scope :admin do
    devise_for :admin_users, controllers: { sessions: "admin/admins/sessions" }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
