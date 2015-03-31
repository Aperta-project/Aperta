TahiStandardTasks::Engine.routes.draw do
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: :create
end
