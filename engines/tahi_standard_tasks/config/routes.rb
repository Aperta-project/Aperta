TahiStandardTasks::Engine.routes.draw do
  resources :export_deliveries, only: [:create, :show]
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: [:create, :update, :destroy]
  put "tasks/:id/upload_manuscript", to: "upload_manuscript#upload", as: :upload_manuscript
  post "tasks/:id/upload_manuscript", to: "upload_manuscript#upload", as: :upload_new_manuscript
  delete "tasks/:id/delete_manuscript", to: "upload_manuscript#destroy_manuscript", as: :destroy_manuscript
  delete "tasks/:id/delete_sourcefile", to: "upload_manuscript#destroy_sourcefile", as: :destroy_sourcefile
end
