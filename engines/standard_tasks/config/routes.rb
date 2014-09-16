StandardTasks::Engine.routes.draw do
  resources :awesome_authors
  resources :funders, only: [:create, :update, :destroy]
  resources :awesome_author
end
