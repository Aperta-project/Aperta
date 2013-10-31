Tahi::Application.routes.draw do
  devise_for :users
  resources :papers, only: [:new, :create, :edit, :update]
  root 'dashboards#index'
end
