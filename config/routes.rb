Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users
  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :figures, only: :create
    resources :submissions, only: [:new, :create]
    resources :tasks, only: :update
    member do
      post :upload
      get :manage, to: 'tasks#index'
    end
  end

  root 'dashboards#index'
end
