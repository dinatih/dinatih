Rails.application.routes.draw do
  root to: 'welcome#index'
  get 'welcome/index'
  devise_for :admins
  devise_for :users
  resources :admins
  resources :articles
  resources :organizations do
    resources :users
  end
  resources :payments
  resources :users
  namespace :admin do
    root 'admins#index'
    resources :admins
    resources :articles
    resources :organizations
    resources :payments
    resources :users
  end
end
