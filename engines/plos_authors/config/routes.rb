PlosAuthors::Engine.routes.draw do
  resources :plos_authors, only: [:create, :update, :destroy]
end
