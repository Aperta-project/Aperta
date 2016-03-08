require 'sidekiq/web'

Tahi::Application.routes.draw do
  mount TahiStandardTasks::Engine => '/api', as: 'standard_tasks'
  ### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###
  mount PlosBioInternalReview::Engine => '/api'
  mount PlosBioTechCheck::Engine => '/api'
  mount PlosBilling::Engine => '/api'


  # Test specific
  #
  if Rails.env.test?
    require_relative '../spec/support/upload_server/upload_server'
    mount UploadServer, at: '/fake_s3/'
  end


  # Authentication
  #
  devise_for :users, controllers: {
    omniauth_callbacks: 'tahi_devise/omniauth_callbacks',
    registrations: 'tahi_devise/registrations'
  }
  devise_scope :user do
    if !Rails.configuration.password_auth_enabled
      # devise will not auto create this route if :database_authenticatable is not enabled
      get 'users/sign_in' => 'devise/sessions#new', as: :new_user_session
    end
    get 'users/sign_out' => 'devise/sessions#destroy'
  end

  authenticate :user, ->(u) { u.site_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end


  # Internal API
  # TODO: namespace to api
  #
  scope '/api', constraints: { format: :json } do
    resources :countries, only: :index

    get 'paper_tracker', to: 'paper_tracker#index'
    resources :supporting_information_files, only: [:show, :create, :destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :affiliations, only: [:index, :create, :destroy]
    resources :attachments, only: [:show, :destroy, :update]
    resources :authors, only: [:show, :create, :update, :destroy]
    resources :collaborations, only: [:create, :destroy]
    resources :comments, only: [:create, :show]
    resources :comment_looks, only: [:index, :show, :destroy]
    resources :decisions, only: [:create, :update, :show]
    resources :discussion_topics, only: [:index, :show, :create, :update]
    resources :discussion_participants, only: [:create, :destroy]
    resources :discussion_replies, only: [:show, :create, :update]
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :figures, only: [:show, :destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :tables, only: [:create, :update, :destroy]
    resources :bibitems, only: [:create, :update, :destroy]
    resources :filtered_users do
      collection do
        get 'admins/:paper_id', to: 'filtered_users#admins'
        get 'editors/:paper_id', to: 'filtered_users#editors'
        get 'users/:paper_id', to: 'filtered_users#users'
        get 'uninvited_users/:paper_id', to: 'filtered_users#uninvited_users'
      end
    end
    resources :flows, except: [:new, :edit]
    resources :formats, only: [:index]
    resources :invitations, only: [:index, :show, :create, :destroy] do
      put :accept, on: :member
      put :reject, on: :member
    end
    resources :journals, only: [:index, :show] do
      resources :old_roles, only: :index, shallow: true do
        namespace 'old_roles', path: '' do
          resources :users, only: :index
        end
      end
    end
    resources :manuscript_manager_templates, only: [:create, :show, :update, :destroy]
    resources :notifications, only: [:index, :show, :destroy]
    resources :assignments, only: [:index, :create, :destroy]
    resources :papers, only: [:index, :create, :show, :update] do
      resources :old_roles, only: :index, controller: 'paper_roles' do
        resources :users, only: :index, controller: 'paper_role_users'
      end
      resource :editor, only: :destroy
      resource :manuscript_manager, only: :show
      resources :figures, only: [:create, :index]
      resources :tables, only: :create
      resources :bibitems, only: :create
      resources :phases, only: :index
      resources :decisions, only: :index
      resources :discussion_topics, only: :index

      resources :tasks, only: [:index, :update, :create, :destroy] do
        resources :comments, only: :create
      end
      member do
        get '/status/:id', to: 'paper_conversions#status'
        get 'activity/workflow', to: 'papers#workflow_activities'
        get 'activity/manuscript', to: 'papers#manuscript_activities'
        get :comment_looks
        get :versioned_texts
        get :export, to: 'paper_conversions#export'
        get :export, to: 'paper_conversions#export'
        get :snapshots
        put :submit
        put :withdraw
        put :reactivate
        put :toggle_editable
        put :upload
      end
    end
    resources :paper_tracker_queries, only: [:index, :create, :update, :destroy]
    resources :participations, only: [:create, :show, :destroy]
    resources :phase_templates
    resources :phases, only: [:create, :update, :show, :destroy]
    resources :permissions, only: [:show]
    resources :question_attachments, only: [:create, :update, :show, :destroy]
    resources :questions, only: [:create, :update]

    resources :nested_questions, only: [:index] do
      resources :answers, only: [:create, :update, :destroy], controller: 'nested_question_answers'
    end

    resources :old_roles, only: [:show, :create, :update, :destroy]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      get :nested_questions
      get :nested_question_answers
      resources :attachments, only: [:index, :create, :update, :destroy] do
        put :update_attachment, on: :member
      end
      resources :comments, only: [:index]
      resources :participations, only: [:index]
      resources :questions, only: [:index]
      resources :snapshots, only: [:index]
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
    post 'event_stream/auth', controller: 'api/event_stream',
                              as: :auth_event_stream

    # s3 request policy
    #
    namespace :s3 do
      resource :request_policy, only: [:show]
      get :sign, to: 'forms#sign'
    end
  end

  # epub/pdf paper download formats
  #
  resources :papers, only: [] do
    get :download, on: :member
  end

  get '/resource_proxy/:resource/:token(/:version)', to: 'resource_proxy#url',
                                                     as: :resource_proxy
  root to: 'ember_cli/ember#index'
  mount_ember_app :tahi, to: '/'
end
