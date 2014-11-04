Tahi::Application.routes.draw do
  mount Kss::Engine => '/kss' if Rails.env.development?
  mount StandardTasks::Engine => '/', as: 'standard_tasks'
  mount SupportingInformation::Engine => '/', as: 'supporting_information'
  mount PlosAuthors::Engine => '/', as: 'plos_custom_authors'
  ### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###

  if Rails.env.development? || Rails.env.test?
    mount QUnit::Rails::Engine => '/qunit'
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.site_admin? } do
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


  get '/flow_manager' => 'ember#index'
  get '/profile' => 'ember#index'

  get '/request_policy' => 'direct_uploads#request_policy'

  get 'filtered_users/users/:paper_id' => 'filtered_users#users', as: "filtered_users"

  resources :flows, only: [:index, :destroy, :create]
  resources :authors, only: [:create, :update, :destroy]

  resources :figures, only: [:destroy, :update] do
    put :update_attachment, on: :member
  end

  resources :comment_looks, only: [:index, :update]

  namespace :api, defaults: { format: 'json' } do
    resources :papers, only: [:index, :show, :update]
    resources :users, only: [:show]
    resources :journals, only: [:index]
  end

  resources :affiliations, only: [:index, :create, :destroy]

  resources :manuscript_manager_templates, only: [:create, :show, :update, :destroy]
  resources :phase_templates
  resources :task_templates

  namespace :admin do
    get 'journals/authorization' => 'journals#authorization'
    resources :journals, only: [:index, :show, :update, :create] do
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

  resources :ihat_jobs, only: :update

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
      put :toggle_editable
      put :submit
    end
  end

  resources :comments, only: [:create, :show]
  resources :participations, only: [:create, :show, :destroy]

  resources :tasks, only: [:update, :create, :show, :destroy] do
    member do
      put :send_message
    end
  end

  resources :phases, only: [:create, :update, :show, :destroy]

  resources :lite_papers, only: :index

  resources :roles, only: [:create, :update, :destroy]
  resources :user_roles, only: [:index, :create, :destroy]

  resources :questions, only: [:create, :update]
  resources :question_attachments, only: [:destroy]
  resources :journal_task_types, only: :update

  resource :dashboards, only: :show

  resource :event_stream, only: :show

  resources :errors, only: :create
  resources :feedback, only: :create

  get '*route' => 'ember#index'
  root 'ember#index'
end
