Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :workouts do
      collection do
        get :existing_dates  # AJAX endpoint for copy feature
      end
    end
    root "workouts#index"
  end

  # get "daily-workout", to: "workouts/today", as: :daily_workout

  root "pages#home"
  get "pages/about",    to: "pages#about",    as: :about
  get "pages/train_with_me", to: "pages#train_with_me", as: :train_with_me
  get "pages/contact",  to: "pages#contact",  as: :contact
  get "pages/testimonials", to: "pages#testimonials", as: :testimonials
end
