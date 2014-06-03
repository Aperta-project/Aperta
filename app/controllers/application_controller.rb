class ApplicationController < ActionController::Base
  include Authorizations

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_bugsnag_notify :add_user_info_to_bugsnag

  # http_basic_authenticate_with name: "tahi", password: "tahi3000", if: -> { %w(production staging).include? Rails.env }

  before_action :authenticate_with_basic_http
  before_filter :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordInvalid, with: :render_errors

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name email username)
  end

  private

  # TODO: move me to policies
  def verify_admin!
    return if current_user.admin?

    if request.xhr? # Ember request
      head :forbidden
    else
      redirect_to(root_path, alert: "Permission denied")
    end
  end

  def render_errors(e)
    render status: 422, json: {errors: e.record.errors}
  end

  # customize devise signout path
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end


  def authenticate_with_basic_http
    if %w(production staging).include?(Rails.env) && request.path !~ /\A\/api.*/
      authenticate_or_request_with_http_basic 'Staging' do |name, password|
        name == 'tahi' && password == 'tahi3000'
      end
    end
  end

  def add_user_info_to_bugsnag(notif)
    return unless current_user.present?

    notif.user = {
      id: current_user.id,
      username: current_user.username,
      name: current_user.full_name,
      email: current_user.email,
      admin: current_user.admin?
    }
  end
end
