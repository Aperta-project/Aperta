Tahi::Application.routes.draw do
  get "users/index"
  get "users/update"
  devise_for :users
  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :submissions, only: [:new, :create]
    member do
      post :upload
    end
  end

  namespace :admin do
    resources :users, only: [:index, :update]
  end

  root 'dashboards#index'
end
