TahiStandardTasks::Engine.routes.draw do
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: [:create, :update, :destroy]
  post "register_decision/:id/decide", to: "register_decision#decide"
  post "initial_decision/:id", to: "initial_decision#create"
end
