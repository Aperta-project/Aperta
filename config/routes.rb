Tahi::Application.routes.draw do
  devise_for :users
  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :submissions, only: [:new, :create]
    member do
      post :upload
    end
  end
  root 'dashboards#index'
end
