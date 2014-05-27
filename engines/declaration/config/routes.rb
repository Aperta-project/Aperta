Declaration::Engine.routes.draw do
  resources :surveys, only: [:update]
end
