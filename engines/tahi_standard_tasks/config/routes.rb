TahiStandardTasks::Engine.routes.draw do
  resources :apex_deliveries, only: [:create, :show]
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: [:create, :update, :destroy]
  post "register_decision/:id/decide", to: "register_decision#decide"
  post "initial_decision/:id", to: "initial_decision#create"

  put "tasks/:id/upload_manuscript", to: "upload_manuscript#upload_manuscript", as: :upload_manuscript
end
