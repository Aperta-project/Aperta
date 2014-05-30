StandardTasks::Engine.routes.draw do
  resources :tasks do
    resources :figures, only: :create
  end
  resources :figures, only: [:destroy, :update]
end

