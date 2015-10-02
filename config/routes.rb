require 'sidekiq/web'
require 'sidetiq/web'

Tahi::Application.routes.draw do
  mount TahiStandardTasks::Engine => "/api", as: "standard_tasks"
  ### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###
  mount PlosBioInternalReview::Engine => '/api'
  mount PlosBioTechCheck::Engine => "/api"
  mount PlosBilling::Engine => "/api"


  # Test specific
  #
  if Rails.env.test?
    require_relative "../spec/support/upload_server/upload_server"
    mount UploadServer, at: "/fake_s3/"
  elsif Rails.env.development?
    get "/styleguide" => "styleguide#index"
    mount EmberCLI::Engine => "ember-tests"
  elsif Rails.env.staging?
    get "/styleguide" => "styleguide#index"
  end


  # Authentication
  #
  devise_for :users, controllers: {
    omniauth_callbacks: "tahi_devise/omniauth_callbacks",
    registrations: "tahi_devise/registrations"
  }
  devise_scope :user do
    if !Rails.configuration.password_auth_enabled
      # devise will not auto create this route if :database_authenticatable is not enabled
      get "users/sign_in" => "devise/sessions#new", as: :new_user_session
    end
    get "users/sign_out" => "devise/sessions#destroy"
  end

  authenticate :user, ->(u) { u.site_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end


  # Internal API
  # TODO: namespace to api
  #
  scope '/api', constraints: { format: :json } do
    namespace :editor do
      get '/crossref/:query', to: 'external_references#crossref'
      get '/doi/:doi', to: 'external_references#doi', constraints: { doi: /.*/ }
    end

    resources :countries, only: :index

    get 'paper_tracker', to: 'paper_tracker#index'
    resources :supporting_information_files, only: [:create, :destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :affiliations, only: [:index, :create, :destroy]
    resources :attachments, only: [:destroy, :update]
    resources :authors, only: [:create, :update, :destroy]
    resources :collaborations, only: [:create, :destroy]
    resources :comments, only: [:create, :show]
    resources :comment_looks, only: [:index, :destroy]
    resources :decisions, only: [:create, :update]
    resources :discussion_topics, only: [:index, :show, :create, :update, :destroy]
    resources :discussion_participants, only: [:create, :destroy]
    resources :discussion_replies, only: [:create, :update, :destroy]
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :figures, only: [:destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :tables, only: [:create, :update, :destroy]
    resources :bibitems, only: [:create, :update, :destroy]
    resources :filtered_users do
      collection do
        get "admins/:paper_id", to: "filtered_users#admins"
        get "editors/:paper_id", to: "filtered_users#editors"
        get "academic_editors/:paper_id", to: "filtered_users#academic_editors"
        get "users/:paper_id", to: "filtered_users#users"
        get "uninvited_users/:paper_id", to: "filtered_users#uninvited_users"
      end
    end
    resources :flows, except: [:new, :edit]
    resources :formats, only: [:index]
    resources :invitations, only: [:index, :create, :destroy] do
      put :accept, on: :member
      put :reject, on: :member
    end
    resources :journal_task_types, only: :update
    resources :journals, only: [:index, :show] do
      resources :roles, only: :index, shallow: true do
        namespace "roles", path: '' do
          resources :users, only: :index
        end
      end
    end
    resources :manuscript_manager_templates, only: [:create, :show, :update, :destroy]
    resources :assignments, only: [:index, :create, :destroy]
    resources :papers, only: [:index, :create, :show, :update] do
      resources :roles, only: :index, controller: "paper_roles" do
        resources :users, only: :index, controller: "paper_role_users"
      end
      resource :editor, only: :destroy
      resource :academic_editor, only: :destroy
      resource :manuscript_manager, only: :show
      resources :figures, only: :create
      resources :tables, only: :create
      resources :bibitems, only: :create
      resources :tasks, only: [:update, :create, :destroy] do
        resources :comments, only: :create
      end
      member do
        get "/status/:id", to: "paper_conversions#status"
        get "activity/workflow", to: "papers#workflow_activities"
        get "activity/manuscript", to: "papers#manuscript_activities"
        get :comment_looks
        get :export, to: "paper_conversions#export"
        put :heartbeat
        put :submit
        put :withdraw
        put :reactivate
        put :toggle_editable
        put :upload
      end
    end
    resources :participations, only: [:create, :show, :destroy]
    resources :phase_templates
    resources :phases, only: [:create, :update, :show, :destroy]
    resources :question_attachments, only: [:destroy]
    resources :questions, only: [:create, :update]
    resources :roles, only: [:show, :create, :update, :destroy]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :attachments, only: [:create, :update, :destroy] do
        put :update_attachment, on: :member
      end
      put :send_message, on: :member
    end
    resources :task_templates
    resources :users, only: [:show, :index] do
      get :reset, on: :collection
      put :update_avatar, on: :collection
    end
    resources :user_flows do
      get :authorization, on: :collection
      get :potential_flows, on: :collection
    end
    resources :user_roles, only: [:index, :create, :destroy]
    resources :versioned_texts, only: [:show]

    # Internal Admin API
    #
    namespace :admin do
      resources :journal_users, only: [:index, :update] do
        get :reset, on: :member
      end
      resources :journals, only: [:index, :show, :update, :create] do
        get :authorization, on: :collection
        put :upload_epub_cover, on: :member
        put :upload_logo, on: :member
      end
    end

    # ihat endpoints
    #
    namespace :ihat do
      resources :jobs, only: [:create]
    end

    # event stream
    #
    post "event_stream/auth", controller: "api/event_stream", as: :auth_event_stream

    # s3 request policy
    #
    namespace :s3 do
      resource :request_policy, only: [:show]
    end
  end

  # epub/pdf paper download formats
  #
  resources :papers, only: [], constraints: { format: /(pdf|epub)/ } do
    get :download, on: :member
  end


  # Fall through to ember app
  #
  get "*route", to: "ember#index", constraints: { format: /html/ }

  root "ember#index"
end
