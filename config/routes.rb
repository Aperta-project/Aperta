Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users

  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :figures, only: :create
    resources :submissions, only: [:new, :create]
    resources :tasks, only: [:update, :create, :show, :new]
    member do
      patch :upload
      get :manage, to: 'tasks#index'
    end
  end

  resource :flow_manager, only: :show

  resource :user_settings, only: :update

  root 'dashboards#index'
end
