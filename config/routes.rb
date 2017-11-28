require 'sidekiq/web'
require 'sidekiq-scheduler/web'

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
    resources :affiliations, only: [:index, :create, :destroy, :update] do
      collection do
        get '/user/:user_id', to: 'affiliations#for_user'
      end
    end

    get '/orcid/oauth', action: 'callback', controller: 'orcid_oauth'

    resources :orcid_accounts, only: [:show] do
      put 'clear', on: :member
    end

    resources :attachments, only: [:show, :destroy, :update], controller: 'adhoc_attachments' do
      put :cancel, on: :member
    end
    resources :manuscript_attachments, only: [:show] do
      put :cancel, on: :member
    end
    resources :sourcefile_attachments, only: [:show] do
      put :cancel, on: :member
    end
    resources :similarity_checks, only: [:create, :show, :update] do
      member do
        get 'report_view_only'
      end
    end
    resources :at_mentionable_users, only: [:index]
    resources :authors, only: [:show, :create, :update, :destroy]

    get "/answers/:owner_type/:owner_id", to: "answers#index", as: "answers_for_owner"
    resources :answers, only: [:show, :create, :destroy, :update]
    resources :repetitions, only: [:create, :update, :destroy]
    resources :cards do
      put :publish, on: :member
      put :archive, on: :member
      put :revert, on: :member
    end

    resources :card_permissions, only: [:create, :show, :update], controller: 'card_permissions'

    resources :card_versions, only: [:show]

    resources :authors, only: [:show, :create, :update, :destroy] do
      put :coauthor_confirmation, on: :member
    end
    resources :collaborations, only: [:create, :destroy]
    resources :comments, only: [:create, :show]
    resources :comment_looks, only: [:index, :show, :destroy]
    resources :decisions, only: [:create, :update, :show] do
      put :rescind, on: :member
      put :register, on: :member
      resources :attachments, only: [:index, :create, :update, :destroy], controller: 'decision_attachments' do
        put :update_attachment, on: :member
      end
    end
    resources :decision_attachments, only: [:index, :show, :create, :update, :destroy]
    resources :discussion_topics, only: [:index, :show, :create, :update] do
      get :users, on: :member
    end
    resources :discussion_participants, only: [:create, :destroy, :show]
    resources :discussion_replies, only: [:show, :create, :update]
    resources :errors, only: :create
    resources :feedback, only: :create
    resources :figures, only: [:show, :destroy, :update] do
      put :update_attachment, on: :member
      put :cancel, on: :member
    end
    resources :group_authors, only: [:show, :create, :update, :destroy]
    resources :bibitems, only: [:create, :update, :destroy]
    resources :filtered_users do
      collection do
        get 'users/:paper_id', constraints: { paper_id: /(#{Journal::SHORT_DOI_FORMAT})|\d+/ },
                               to: 'filtered_users#users'
        get 'assignable_users/:task_id', to: 'filtered_users#assignable_users'
      end
    end
    resources :formats, only: [:index]
    resources :invitations, only: [:index, :show, :create, :update, :destroy] do
      put :accept,  on: :member
      put :decline, on: :member
      put :rescind, on: :member
      put :send_invite, on: :member
      put :update_position, on: :member
      put :update_primary, on: :member
      get :details, on: :member
      resources :attachments, only: [:index, :create, :update, :destroy, :show], controller: 'invitation_attachments' do
        put :update_attachment, on: :member
      end
    end
    resources :journals, only: [:index, :show] do
      get :manuscript_manager_templates, to: 'manuscript_manager_templates#index'
      get :cards, to: 'cards#index'
    end

    resources :manuscript_manager_templates
    resources :notifications, only: [:index, :show, :destroy]
    resources :assignments, only: [:index, :create, :destroy]
    resources :papers, param: :id, constraints: { id: /(#{Journal::SHORT_DOI_FORMAT})|\d+/ }, \
                       only: [:index, :create, :show, :update] do
      resources :roles, only: [], controller: 'paper_roles' do
        resources :eligible_users, only: [:index], controller: 'paper_role_eligible_users'
      end
      resource :editor, only: :destroy
      resources :figures, only: [:create, :index]
      resources :tables, only: :create
      resources :bibitems, only: :create
      resources :phases, only: :index
      resources :decisions, only: :index
      resources :discussion_topics, only: :index do
        get :new_discussion_users, on: :collection
      end
      resources :task_types, only: :index, controller: 'paper_task_types'
      resources :available_cards, only: :index
      resources :correspondence, only: [:index, :create, :show, :update] do
        resources :attachments, only: [:create, :update, :destroy, :show], controller: :correspondence_attachments
      end
      resources :similarity_checks, only: :index

      resources :tasks, only: [:index, :update, :create, :destroy] do
        resources :comments, only: :create
      end
      member do
        get '/status/:id', to: 'paper_conversions#status'
        get 'activity/workflow', to: 'papers#workflow_activities'
        get 'activity/manuscript', to: 'papers#manuscript_activities'
        get :comment_looks
        get :versioned_texts
        get :snapshots
        get :related_articles
        put :submit
        put :withdraw
        put :reactivate
        put :toggle_editable
      end
    end
    resources :paper_downloads, only: [:show]
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

    resources :related_articles, only: [:show, :create, :update, :destroy]
    resources :reviewer_reports, only: [:show, :update]
    resources :due_datetimes, only: [:update]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      get :nested_questions
      get :nested_question_answers
      put :update_position
      resources :attachments, only: [:index, :create, :update, :destroy], controller: 'adhoc_attachments' do
        put :update_attachment, on: :member
      end
      resources :comments, only: [:index]
      resources :participations, only: [:index]
      resources :questions, only: [:index]
      resources :repetitions, only: [:index]
      resources :snapshots, only: [:index]
      put :send_message, on: :member
      put :sendback_email, on: :member
      put :sendback_preview, on: :member
      namespace :eligible_users, module: nil do
        get 'admins', to: 'task_eligible_users#admins'
        get 'academic_editors', to: 'task_eligible_users#academic_editors'
        get 'reviewers', to: 'task_eligible_users#reviewers'
      end
    end
    resources :task_templates do
      put :update_setting, on: :member
    end
    resources :token_invitations, only: [:show, :update], param: :token
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
      end
      resources :letter_templates, only: [:index, :show, :update, :create]
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
      get :sign, to: 'forms#sign'
    end

    resources :feature_flags, only: [:index, :update]

    put 'scheduled_events/:id/update_state',
      to: 'scheduled_events#update_state'
  end

  get '/invitations/:token/accept',
    to: 'token_invitations#accept',
    as: 'invitation_accept'

  get '/co_authors_token/:token',
    to: 'token_co_authors#show',
    as: 'show_token_co_author'

  put '/co_authors_token/:token/confirm',
    to: 'token_co_authors#confirm',
    as: 'confirm_token_co_author'

  get '/co_authors_token/:token/thank_you',
    to: 'token_co_authors#thank_you',
    as: 'thank_you_token_co_author'

  get '/co_authors_token/:token/authorship_refuted',
    to: 'token_co_authors#authorship_refuted',
    as: 'authorship_refuted_token_co_author'

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
        /x
      },
      to: 'resource_proxy#url', as: :old_resource_proxy

  # current resource proxy
  get '/resource_proxy/:token(/:version)', to: 'resource_proxy#url',
                                           as: :resource_proxy

  scope constraints: ->(request) { request.fullpath =~ Journal::SHORT_DOI_FORMAT } do
    get('/(*rest)', controller: "ember_cli/ember",
                    action: "index",
                    format: :html,
                    defaults: { ember_app: :client })
  end

  root to: 'ember_cli/ember#index'
  health_check_routes
  mount_ember_app :client, to: '/'
end
