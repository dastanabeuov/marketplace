Rails.application.routes.draw do
  # ⬇️only client resources⬇️
  root to: "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :companies, only: [ :index, :show ] do
    member do
      get "product/:product_id", to: "companies#product", as: "product"
    end
  end
  resource :contact, only: :show
  resource :about, only: :show
  resource :privacy_policy, only: :show
  resource :terms_of_use_site, only: :show
  resources :mechanics, only: [ :index, :show ]
  resources :products,  only: [ :index, :show ]
  resources :vacancies, only: [ :index, :show ]

  # ⬇️only admin resources⬇️
  namespace :admin do
    root to: "main#index"
    mount ActiveStorageDashboard::Engine, at: "/active-storage-dashboard"

    concern :removable_image do
      member { delete :remove_image }
    end

    resources :companies, concerns: :removable_image
    resources :categories do
      collection do
        get :search_company
      end
    end

    resources :products, concerns: :removable_image do
      collection do
        get :search_category
        get :search_company
      end
    end

    resource :sitename, concerns: :removable_image
    resource :contact, concerns: :removable_image
    resource :about, concerns: :removable_image
    resources :vacancies
    resources :mechanics, concerns: :removable_image
    resource :privacy_policy
    resource :terms_of_use_site
  end

  scope :admin do
    devise_for :admin_users, controllers: { sessions: "admin/admins/sessions" }
  end
end
