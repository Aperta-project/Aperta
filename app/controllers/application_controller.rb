class ApplicationController < ActionController::Base
  include Authorizations
  include TahiPusher::SocketTracker

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_bugsnag_notify :add_user_info_to_bugsnag

  before_action :authenticate_with_basic_http
  before_action :set_pusher_socket
  before_action :set_invitation_code
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordInvalid, with: :render_errors
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name email username)
  end

  # called every request
  def set_invitation_code
    # Look for an invitation_code in query params
    invitation_code = params["invitation_code"]

    # Set the invitation_code in the Session
    if invitation_code.present?
      session["invitation_code"] = invitation_code
    end

    # Set @invitation_code for all Controllers
    if session["invitation_code"].present?
      @invitation_code = session["invitation_code"]
    end
  end

  # called after login or signup
  def associate_user_by_invitation_code(user)
    # if we have an invitation_code in the session, try to associate it with the user
    if @invitation_code
      invitation = Invitation.where(code: @invitation_code).first

      if invitation
        invitation.update(invitee: user)
      end

      clear_invitation_code # clear if we found an invitation or not
    end
  end

  def clear_invitation_code
    session["invitation_code"] = nil
    @invitation_code = nil
  end

  def unmunge_empty_arrays!(model_key, model_attributes)
    model_attributes.each do |key|
      if params[model_key].has_key?(key) && params[model_key][key].nil?
        params[model_key][key] = []
      end
    end
  end

  private

  def render_errors(e)
    render status: 422, json: {errors: e.record.errors}
  end

  def render_404
    head 404
  end

  # customize devise signout path
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def authenticate_with_basic_http
    return unless Rails.configuration.basic_auth_required
    return if request.path =~ /\A\/api.*/

    unless session[:authenticated]
      authenticate_or_request_with_http_basic do |name, password|
        name == Rails.configuration.basic_auth_user && password == Rails.configuration.basic_auth_password && (session[:authenticated] = true)
      end
    end
  end

  def add_user_info_to_bugsnag(notification)
    return unless current_user.present?

    notification.user = {
      id: current_user.id,
      username: current_user.username,
      name: current_user.full_name,
      email: current_user.email,
      site_admin: current_user.site_admin?
    }
  end
end
