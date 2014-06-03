StandardTasks::Engine.routes.draw do
  resources :figures, only: [:create, :destroy, :update]
end

