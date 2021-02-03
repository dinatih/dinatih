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
    resources :payments, concerns: :bootstrap_tableable
    resources :users
  end

  resources :payments
  resources :users
end
