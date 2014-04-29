Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  if Rails.env.test?
    require_relative '../spec/support/stream_server/stream_server'
    get '/stream' => StreamServer
    post '/update_stream' => StreamServer
  end

  devise_for :users
  devise_scope :user do
    get "users/sign_out" => "devise/sessions#destroy"
  end

  resources :journals, only: [:index]

  get '/flow_manager' => 'ember#index'

  resources :flows, only: [:index, :destroy, :create]

  resources :figures, only: :destroy

  namespace :api do
    resources :papers, only: [:index, :show, :update]
    resources :users, only: [:show]
  end

  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :figures, only: :create
    resources :submissions, only: [:new, :create]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :comments, only: :create
    end

    resources :messages, only: [:create] do
      member do
        patch :update_participants
      end
    end

    member do
      patch :upload
      get :manage, to: 'ember#index'
      get :download
    end
  end

  resources :comments, only: :create

  resources :message_tasks, only: [:create] do
    member do
      patch :update_participants
    end
  end

  resources :tasks

  resources :phases, only: [:create, :update, :show, :destroy]

  resources :surveys, only: [:update]

  get 'users/dashboard_info', to: 'user_info#dashboard', defaults: {format: 'json'}

  root 'ember#index'
  resource :event_stream, only: :show
end
