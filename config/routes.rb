# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :teams do
        resources :chores, except: :index do
          resources :chore_executions, only: [:create, :destroy, :index]
        end
      end
      resources :chores, only: :index
      resources :chore_executions, only: :index
      get '/managers', to: 'team_members#managers_list'
      get '/users', to: 'team_members#users_list'
    end
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
