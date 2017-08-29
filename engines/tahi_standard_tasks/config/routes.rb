TahiStandardTasks::Engine.routes.draw do
  resources :export_deliveries, only: [:create, :show]
  resources :funders, only: [:create, :update, :destroy]
  resources :reviewer_recommendations, only: [:create, :update, :destroy]
  put "tasks/:id/upload_manuscript", to: "upload_manuscript#upload_manuscript", as: :upload_manuscript
  post "tasks/:id/upload_manuscript", to: "upload_manuscript#upload_manuscript", as: :upload_new_manuscript
  put "tasks/:id/upload_sourcefile", to: "upload_sourcefile#upload_sourcefile", as: :upload_sourcefile
  post "tasks/:id/upload_sourcefile", to: "upload_sourcefile#upload_sourcefile", as: :upload_new_sourcefile
end
