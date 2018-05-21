# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class ApplicationController < ActionController::Base
  include AuthorizationsControllerHelper
  include TahiPusher::SocketTracker
  include TahiPusher::CurrentUserTracker

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session

  before_bugsnag_notify :add_user_info_to_bugsnag

  before_action :authenticate_with_basic_http
  before_action :set_pusher_socket
  before_action :set_current_user_id
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_location_for_login_redirect, if: :should_store_redirect?

  rescue_from ActiveRecord::RecordInvalid, with: :render_errors
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  # This is an error we use to allow assertions of the form:
  # `assert test?, "Error message", status_code: 422`
  # in controllers. See #assert, below.
  class AssertionError < StandardError
    attr_reader :message, :status_code

    def initialize(message, status_code)
      @message = message
      @status_code = status_code
    end
  end

  rescue_from AssertionError, with: :render_assertion_error

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name email username)
  end

  def unmunge_empty_arrays!(model_key, model_attributes)
    model_attributes.each do |key|
      if params[model_key].has_key?(key) && params[model_key][key].nil?
        params[model_key][key] = []
      end
    end
  end

  # allow the remote ip address to be logged with each request
  # https://github.com/roidrage/lograge/issues/10
  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
  end

  private

  def render_errors(e)
    render status: 422, json: { errors: e.record.errors }
  end

  def assert(test, message, status_code: 422)
    raise AssertionError.new(message, status_code) unless test
  end

  def render_assertion_error(e)
    render status: e.status_code, json: { errors: [e.message] }
  end

  def render_404
    head 404
  end

  # customize devise signout path
  def after_sign_out_path_for(_resource_or_scope)
    cas_logout_url || new_user_session_path
  end

  def new_session_path(_scope)
    new_user_session_path
  end

  # Store the page the user was on if they are making an API call. If
  # the user loses their session we want to redirect them back where
  # they were before.
  def location_for_redirect
    if request.url.include?('/api')
      request.referer
    else
      request.url
    end
  end

  # to redirect a user to the requested page after login
  def store_location_for_login_redirect
    store_location_for(:user, location_for_redirect)
  end

  def should_store_redirect?
    !devise_controller? && !user_signed_in?
  end

  def cas_logout_url
    return unless TahiEnv.cas_logout_url
    query = { service: new_user_session_url }.to_query

    logout_uri = URI.parse(TahiEnv.cas_logout_url)
    if logout_uri.relative?
      protocol = TahiEnv.cas_ssl? ? 'https://' : 'http://'
      logout_uri = URI.join("#{protocol}#{TahiEnv.cas_host}", logout_uri)
    end
    URI.join(logout_uri, "?#{query}").to_s
  end

  def authenticate_with_basic_http
    return unless TahiEnv.basic_auth_required?
    # Make assets available for bugsnag
    return if request.path =~ %r{\A/(api|assets).*\Z}

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
