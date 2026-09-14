Rails.application.routes.draw do
  # Admin panel. Session-based, separate from the JSON API below.
  get  "admin/login",  to: "admin_sessions#new",     as: :admin_login
  post "admin/login",  to: "admin_sessions#create"
  delete "admin/logout", to: "admin_sessions#destroy", as: :admin_logout

  mount_avo

  # Public JSON API consumed by the Express BFF.
  namespace :api do
    get "health", to: "health#show"
    get "search", to: "search#index"

    # Auth. The Express BFF calls these and keeps the token in an httpOnly
    # cookie; the browser never sees it.
    post "auth/signup", to: "registrations#create"
    post "auth/login", to: "sessions#create"
    get "auth/me", to: "me#show"

    resources :courses, only: %i[index], param: :slug
    get "courses/:slug", to: "courses#show", as: :course

    resources :trips, only: %i[index], param: :slug
    get "trips/:slug", to: "trips#show", as: :trip

    resources :articles, only: %i[index], param: :slug
    get "articles/:slug", to: "articles#show", as: :article

    resources :schedules, only: %i[index show]
    resources :instructors, only: %i[index]
    resources :bookings, only: %i[index create destroy]
  end

  # Returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
