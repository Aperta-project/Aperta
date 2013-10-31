Tahi::Application.routes.draw do
  devise_for :users
  resources :papers, only: [:new, :create, :edit, :update] do
    member do
      post :upload
    end
  end
  root 'dashboards#index'
end
