Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'
  mount FinancialDisclosure::Engine => '/', as: 'financial_disclosure'

  if Rails.env.development? || Rails.env.test?
    mount QUnit::Rails::Engine => '/qunit'
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  if Rails.env.test?
    require_relative '../spec/support/stream_server/stream_server'
    require_relative '../spec/support/upload_server/upload_server'
    get '/stream' => StreamServer
    post '/update_stream' => StreamServer
    mount UploadServer, at: '/fake_s3/'
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "registrations" }
  devise_scope :user do
    get "users/sign_out" => "devise/sessions#destroy"
  end

  resources :journals, only: [:index, :show]

  namespace 'admin' do
    resources :journals, only: [:update, :create]
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
    resources :journals, only: :index do
      put :upload_epub_cover, on: :member
      put :upload_logo, on: :member
    end

    resources :journal_users, only: [:index, :update] do
      get :reset, on: :member
    end
  end

  resources :users, only: [:show, :index] do
    put :update_avatar, on: :member
  end

  resources :collaborations, only: [:create, :destroy]
  resources :paper_roles, only: [:show]

  resources :papers, only: [:create, :show, :edit, :update] do
    resources :figures, only: :create
    resource :manuscript_manager, only: :show
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :comments, only: :create
    end

    member do
      put :upload
      get :manage, to: 'ember#index'
      get :download
      put :heartbeat
    end
  end

  resources :comments, only: [:create, :show]

  resources :tasks, only: [:update, :create, :show, :destroy] do
    collection do
      get :task_types
    end
  end

  resources :phases, only: [:create, :update, :show, :destroy]

  resources :lite_papers, only: :index

  resources :roles, only: [:create, :update, :destroy]
  resources :user_roles, only: [:index, :create, :destroy]

  resources :questions, only: [:create, :update, :destroy]

  resource :dashboards, only: :show

  resource :event_stream, only: :show

  get '*route' => 'ember#index'
  root 'ember#index'
end
