require 'sidekiq/web'

# rubocop:disable Metrics/LineLength
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
    unless Rails.configuration.password_auth_enabled
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
    resources :institutional_accounts, only: :index

    get 'paper_tracker', to: 'paper_tracker#index'
    resources :supporting_information_files, only: [:show, :create, :destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :affiliations, only: [:index, :create, :destroy]
    resources :attachments, only: [:show, :destroy, :update], controller: 'adhoc_attachments'
    resources :at_mentionable_users, only: [:index]
    resources :authors, only: [:show, :create, :update, :destroy]
    resources :collaborations, only: [:create, :destroy]
    resources :comments, only: [:create, :show]
    resources :comment_looks, only: [:index, :show, :destroy]
    resources :decisions, only: [:create, :update, :show]
    resources :discussion_topics, only: [:index, :show, :create, :update] do
      get :users, on: :member
    end
    resources :discussion_participants, only: [:create, :destroy, :show]
    resources :discussion_replies, only: [:show, :create, :update]
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :figures, only: [:show, :destroy, :update] do
      put :update_attachment, on: :member
    end
    resources :group_authors, only: [:show, :create, :update, :destroy]
    resources :tables, only: [:create, :update, :destroy]
    resources :bibitems, only: [:create, :update, :destroy]
    resources :filtered_users do
      collection do
        get 'users/:paper_id', to: 'filtered_users#users'
      end
    end
    resources :formats, only: [:index]
    resources :invitations, only: [:index, :show, :create, :update] do
      put :accept, on: :member
      put :decline, on: :member
      put :rescind, on: :member
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
      resources :roles, only: [], controller: 'paper_roles' do
        resources :eligible_users, only: [:index], controller: 'paper_role_eligible_users'
      end
      resource :editor, only: :destroy
      resource :manuscript_manager, only: :show
      resources :figures, only: [:create, :index]
      resources :tables, only: :create
      resources :bibitems, only: :create
      resources :phases, only: :index
      resources :decisions, only: :index
      resources :discussion_topics, only: :index
      resources :task_types, only: :index, controller: 'paper_task_types'

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
        get :snapshots
        get :related_articles
        put :submit
        put :withdraw
        put :reactivate
        put :toggle_editable
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

    resources :related_articles, only: [:show, :create, :update, :destroy]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      get :nested_questions
      get :nested_question_answers
      resources :attachments, only: [:index, :create, :update, :destroy], controller: 'adhoc_attachments' do
        put :update_attachment, on: :member
      end
      resources :comments, only: [:index]
      resources :participations, only: [:index]
      resources :questions, only: [:index]
      resources :snapshots, only: [:index]
      put :send_message, on: :member
      namespace :eligible_users, module: nil do
        get 'admins', to: 'task_eligible_users#admins'
        get 'academic_editors', to: 'task_eligible_users#academic_editors'
        get 'reviewers', to: 'task_eligible_users#reviewers'
      end
    end
    resources :task_templates
    resources :users, only: [:show, :index] do
      get :reset, on: :collection
      put :update_avatar, on: :collection
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

  get '/invitations/:token',
    to: 'token_invitations#show',
    as: 'confirm_decline_invitation'

  post '/invitations/:token/decline',
    to: 'token_invitations#decline',
    as: 'decline_token_invitation'

  get '/invitations/:token/feedback',
    to: 'token_invitations#feedback_form',
    as: 'invitation_feedback_form'

  post '/invitations/:token/feedback',
    to: 'token_invitations#feedback',
    as: 'post_feedback'

  get '/invitations/:token/thank_you',
    to: 'token_invitations#thank_you',
    as: 'invitation_thank_you'

  # Legacy resource_proxy routes
  # We need to maintain this route as existing resources have been linked with
  # this scheme.
  get '/resource_proxy/:resource/:token(/:version)',
      constraints: {
        resource: /
          adhoc_attachments
          | attachments
          | question_attachments
          | figures
          | supporting_information_files
        /x },
      to: 'resource_proxy#url', as: :old_resource_proxy

  # current resource proxy
  get '/resource_proxy/:token(/:version)', to: 'resource_proxy#url',
                                           as: :resource_proxy

  root to: 'ember_cli/ember#index'
  mount_ember_app :client, to: '/'
end
