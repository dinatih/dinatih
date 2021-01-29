Rails.application.routes.draw do
  devise_for :admins
  devise_for :users

  namespace :admin do
    root 'admins#index'
    resources :admins
    resources :articles
    resources :organizations
    resources :payments
    resources :users
  end

  resources :admins
  resources :articles

  resources :organizations do
    namespace :admin do
      resources :articles
      resources :payments
      resources :users
    end

    resources :articles
    resources :payments
    resources :users
  end

  resources :payments
  resources :users
end
