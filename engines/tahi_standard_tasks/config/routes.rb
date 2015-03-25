TahiStandardTasks::Engine.routes.draw do
  resources :funders, only: [:create, :update, :destroy]
end
