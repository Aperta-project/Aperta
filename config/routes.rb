Tahi::Application.routes.draw do
  devise_for :users
  resources :papers, only: [:new, :create, :edit]
  root 'dashboards#index'
end
