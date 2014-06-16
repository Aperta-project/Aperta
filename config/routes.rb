Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'
  mount Declaration::Engine => '/', :as => 'declaration_engine'

  if Rails.env.test?
    require_relative '../spec/support/stream_server/stream_server'
    get '/stream' => StreamServer
    post '/update_stream' => StreamServer
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "registrations" }
  devise_scope :user do
    get "users/sign_out" => "devise/sessions#destroy"
  end

  resources :journals, only: [:index, :show]

  namespace 'admin' do
    resources :journals, only: :update
  end

  get '/flow_manager' => 'ember#index'
  get '/profile' => 'ember#index'

  get '/request_policy' => 'direct_uploads#request_policy'

  resources :flows, only: [:index, :destroy, :create]
  resources :authors, only: [:create, :update, :destroy]
  resources :author_groups, only: [:create, :destroy]

  resources :figures, only: [:destroy, :update] do
    put :update_attachment, on: :member
  end

  resources :files, as: 'supporting_information_files',
                    path: 'supporting_information_files',
                    only: [:create, :destroy, :update],
                    controller: 'supporting_information/files'

  resources :comment_looks, only: [:update]

  namespace :api, defaults: { format: 'json' } do
    resources :papers, only: [:index, :show, :update]
    resources :users, only: [:show]
    resources :journals, only: [:index]
  end

  resources :affiliations, only: [:index, :create, :destroy]

  resources :manuscript_manager_templates

  namespace :admin do
    resources :journals, only: [:index] do
      put :upload_epub_cover, on: :member
    end
  end

  resources :users, only: [:show] do
    get :profile, on: :collection
    put :update_avatar, on: :member
  end

  resources :papers, only: [:create, :show, :edit, :update] do
    resources :figures, only: :create
    resource :manuscript_manager, only: :show
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :comments, only: :create
    end

    resources :messages, only: [:create] do
      member do
        patch :update_participants
      end
    end

    member do
      put :upload
      get :manage, to: 'ember#index'
      get :download
    end
  end

  resources :comments, only: :create

  resources :message_tasks, only: [:create] do
    member do
      patch :update_participants
    end
  end

  resources :tasks, only: [:update, :create, :show, :destroy] do
    collection do
      get :task_types
    end
  end

  resources :phases, only: [:create, :update, :show, :destroy]

  resources :roles, only: [:create, :update, :destroy]

  get '/dashboard_info', to: 'user_info#dashboard', defaults: {format: 'json'}

  resource :event_stream, only: :show

  get '*route' => 'ember#index'
  root 'ember#index'
end
