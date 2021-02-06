# frozen_string_literal: true

Rails.application.routes.draw do
  concern :bootstrap_tableable do
    get :table_columns, on: :collection
  end

  devise_for :admins
  devise_for :users

  namespace :admin do
    root 'admins#index'
    resources :admins
    resources :articles
    resources :organizations
    resources :payins
    resources :payouts
    resources :users
  end

  resources :admins

  resources :organizations do
    namespace :admin do
      resources :articles
      resources :payins
      resources :payouts
      resources :users
    end

    resources :articles, concerns: :bootstrap_tableable
    resources :products, concerns: :bootstrap_tableable
    resources :payins, concerns: :bootstrap_tableable
    resources :payouts, concerns: :bootstrap_tableable
    resources :users, concerns: :bootstrap_tableable
  end

  resources :articles, concerns: :bootstrap_tableable
  resources :products, concerns: :bootstrap_tableable
  resources :payins, concerns: :bootstrap_tableable
  resources :payouts, concerns: :bootstrap_tableable
  resources :users
end
