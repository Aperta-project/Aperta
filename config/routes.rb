require 'sidekiq/web'
require 'sidetiq/web'

Tahi::Application.routes.draw do
  mount TahiStandardTasks::Engine => "/", as: "standard_tasks"
  mount PlosAuthors::Engine => "/", as: "plos_custom_authors"
  ### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###
  mount PlosBioTechCheck::Engine => "/"
  mount PlosBilling::Engine => "/"
  mount TahiSupportingInformation::Engine => "/", as: "tahi_supporting_information"


  # Test specific
  #
  if Rails.env.test?
    # TODO: Remove the need for this with pusher
    require_relative "../spec/support/stream_server/stream_server"
    require_relative "../spec/support/upload_server/upload_server"
    get "/stream" => StreamServer
    post "/update_stream" => StreamServer
    mount UploadServer, at: "/fake_s3/"
  elsif Rails.env.development?
    mount EmberCLI::Engine => "ember-tests"
  end


  # Authentication
  #
  devise_for :users, controllers: {
    omniauth_callbacks: "tahi_devise/omniauth_callbacks",
    registrations: "tahi_devise/registrations"
  }
  devise_scope :user do
    get "users/sign_out" => "devise/sessions#destroy"
  end
  authenticate :user, ->(u) { u.site_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end


  # Internal API
  # TODO: namespace to api
  #
  constraints format: :json do
    resources :affiliations, only: [:index, :create, :destroy]
    resources :attachments, only: [:destroy, :update]
    resources :authors, only: [:create, :update, :destroy]
    resources :collaborations, only: [:create, :destroy]
    resources :comments, only: [:create, :show]
    resources :comment_looks, only: [:index, :update]
    resource :dashboards, only: :show
    resources :decisions, only: [:create, :update]
    resource :event_stream, only: :show
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :figures, only: [:destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :filtered_users do
      collection do
        get "admins/:paper_id", to: "filtered_users#admins"
        get "editors/:paper_id", to: "filtered_users#editors"
        get "reviewers/:paper_id", to: "filtered_users#reviewers"
        get "users/:paper_id", to: "filtered_users#users"
      end
    end
    resources :flows, only: [:show, :create, :update, :destroy]
    resources :formats, only: [:index]
    resources :invitations, only: [:create, :destroy] do
      put :accept, on: :member
      put :reject, on: :member
    end
    resources :journal_task_types, only: :update
    resources :journals, only: [:index, :show]
    resources :lite_papers, only: :index
    resources :manuscript_manager_templates, only: [:create, :show, :update, :destroy]
    resources :paper_roles, only: [:show]
    resources :papers, only: [:create, :show, :update] do
      resource :editor, only: :destroy
      resource :manuscript_manager, only: :show
      resources :figures, only: :create
      resources :tasks, only: [:update, :create, :show, :destroy] do
        resources :comments, only: :create
      end
      resource :user_inbox, only: [:show]
      member do
        get "/:publisher_prefix/:suffix" => "papers#show",
            constraints: { publisher_prefix: Doi::PUBLISHER_PREFIX_FORMAT, suffix: Doi::SUFFIX_FORMAT }
        get "/status/:id", to: "paper_conversions#status"
        get "activity_feed/:name", to: "papers#activity_feed"
        get :export, to: "paper_conversions#export"
        put :heartbeat
        put :submit
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
      resources :attachments, only: [:create]
      put :send_message, on: :member
    end
    resources :task_templates
    resources :users, only: [:show, :index] do
      put :update_avatar, on: :collection
    end
    resources :user_flows do
      get :authorization, on: :collection
      get :potential_flows, on: :collection
    end
    resources :user_inboxes, only: [:destroy]
    resources :user_roles, only: [:index, :create, :destroy]

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

    # s3 request policy
    #
    namespace :s3 do
      resource :request_policy, only: [:show]
    end
  end

  # epub/pdf paper download formats
  #
  resources :papers, only: [], constraints: { format: [:epub, :pdf] } do
    get :download, on: :member
  end


  # Fall through to ember app
  #
  get "*route" => "ember#index"
  root "ember#index"
end
