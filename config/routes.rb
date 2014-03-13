Tahi::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users

  resources :papers, only: [:new, :create, :show, :edit, :update] do
    resources :figures, only: :create
    resources :submissions, only: [:new, :create]
    resources :tasks, only: [:update, :create, :show, :destroy] do
      resources :comments, only: :create
    end

    # event stream route is declared here so it is given the :paper_id param
    get :event_stream, to: "tasks#event_stream"
    # look at making this abstracterized later
    # get '/:controller/:id/event_stream', to: 'application#event_stream'
    # and then make the event listener off of :controller_:id

    resources :messages, only: [:create] do
      member do
        patch :update_participants
      end
    end

    member do
      patch :upload
      get :manage, to: 'tasks#index'
    end
  end

  resource :phases, only: [:create, :update, :destroy]

  get 'users/chosen_options', to: 'user_info#thumbnails', defaults: {format: 'json'}

  resource :flow_manager, only: :show

  resource :user_settings, only: :update

  root 'dashboards#index'
  get :event_stream, to: "dashboards#event_stream"
end
