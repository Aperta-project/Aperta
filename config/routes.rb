require 'sidekiq/web'

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


  # Devise Authentication
  #
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "registrations" }
  devise_scope :user do
    get "users/sign_out" => "devise/sessions#destroy"
  end
  authenticate :user, ->(u) { u.site_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end


  # Internal API
  # TODO: namespace, organize, declutter
  #
  constraints format: :json do
    resources :journals, only: [:index, :show]
    get "/request_policy" => "direct_uploads#request_policy"
    resources :filtered_users do
      collection do
        get "users/:paper_id", to: "filtered_users#users"
        get "editors/:paper_id", to: "filtered_users#editors"
        get "admins/:paper_id", to: "filtered_users#admins"
        get "reviewers/:paper_id", to: "filtered_users#reviewers"
      end
    end
    resources :user_flows do
      get :potential_flows, collection: true
      get :authorization, collection: true
    end
    resources :flows, only: [:show, :create, :update, :destroy]
    resources :authors, only: [:create, :update, :destroy]
    resources :figures, only: [:destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :comment_looks, only: [:index, :update]
    resources :affiliations, only: [:index, :create, :destroy]
    resources :manuscript_manager_templates, only: [:create, :show, :update, :destroy]
    resources :phase_templates
    resources :task_templates
    resources :users, only: [:show, :index] do
      put :update_avatar, collection: true
    end
    resources :collaborations, only: [:create, :destroy]
    resources :paper_roles, only: [:show]
    resources :papers, only: [:create, :show, :update] do
      resources :figures, only: :create
      resource :manuscript_manager, only: :show
      resource :editor, only: :destroy
      resources :tasks, only: [:update, :create, :show, :destroy] do
        resources :comments, only: :create
      end
      member do
        put :upload
        put :heartbeat
        get :export, to: "paper_conversions#export"
        get "/status/:id", to: "paper_conversions#status"
        put :toggle_editable
        put :submit
        get "activity_feed/:name", to: "papers#activity_feed"
        get "/:publisher_prefix/:suffix" => "papers#show",
            constraints: { publisher_prefix: Doi::PUBLISHER_PREFIX_FORMAT, suffix: Doi::SUFFIX_FORMAT }
      end
    end
    resources :comments, only: [:create, :show]
    resources :participations, only: [:create, :show, :destroy]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :attachments, only: [:create]
      put :send_message, member: true
    end
    resources :attachments, only: [:destroy, :update]
    resources :phases, only: [:create, :update, :show, :destroy]
    resources :lite_papers, only: :index
    resources :roles, only: [:show, :create, :update, :destroy]
    resources :user_roles, only: [:index, :create, :destroy]
    resources :questions, only: [:create, :update]
    resources :question_attachments, only: [:destroy]
    resources :journal_task_types, only: :update
    resource :dashboards, only: :show
    resource :event_stream, only: :show
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :invitations, only: [:create, :destroy] do
      member do
        put :accept, :reject
      end
    end
    resources :formats, only: [:index]
    # Internal Admin API
    #
    namespace :admin do
      get "journals/authorization" => "journals#authorization"
      resources :journals, only: [:index, :show, :update, :create] do
        put :upload_epub_cover, on: :member
        put :upload_logo, on: :member
      end
      resources :journal_users, only: [:index, :update] do
        get :reset, on: :member
      end
    end

    # ihat endpoints
    #
    post :ihat_jobs, to: "ihat_jobs#update", as: :ihat_callback
  end
  # epub/pdf download formats
  #
  resources :papers, only: [], constraints: { format: [:epub, :pdf] } do
    get :download, member: true
  end


  # Fall through to ember app
  #
  get "*route" => "ember#index"
  root "ember#index"
end
