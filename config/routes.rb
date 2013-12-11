Tahi::Application.routes.draw do
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

  namespace :admin do
    resources :users, only: [:index, :update]
  end

  root 'dashboards#index'
end
