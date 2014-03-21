Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users

  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :figures, only: :create
    resources :submissions, only: [:new, :create]

    member do
      patch :upload
      get :manage, to: 'tasks#index'
    end
  end

  resources :comments, only: :create

  resources :message_tasks, only: [:create] do
    member do
      patch :update_participants
    end
  end

  resources :tasks, only: [:update, :create, :show, :destroy]

  resources :phases, only: [:create, :update, :destroy]

  resources :declarations, only: [:update]

  get 'ember', to: 'ember#index'

  get 'users/chosen_options', to: 'user_info#thumbnails', defaults: {format: 'json'}

  resource :flow_managers, only: :show

  resource :user_settings, only: :update

  root 'dashboards#index'
end
