TahiStandardTasks::Engine.routes.draw do
  resources :apex_deliveries, only: [:create, :show]
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: [:create, :update, :destroy]
  put "tasks/:id/upload_manuscript", to: "upload_manuscript#upload_manuscript", as: :upload_manuscript
end
