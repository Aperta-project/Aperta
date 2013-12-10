class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  BASIC_AUTH_USERS = { "tahi" => "tahi3000" }

  before_action :basic_auth, if: -> { %w(production staging).include? Rails.env }

  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name affiliation email username)
  end

  def basic_auth
    authenticate_or_request_with_http_digest("Application") do |name|
      BASIC_AUTH_USERS[name]
    end
  end

  private
  def verify_admin!
    redirect_to(root_path, alert: "Permission denied") unless current_user.admin?
  end
end
