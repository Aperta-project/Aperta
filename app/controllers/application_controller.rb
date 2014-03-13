class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: "tahi", password: "tahi3000", if: -> { %w(production staging).include? Rails.env }

  before_filter :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordInvalid, with: :render_errors

  def event_stream
    data = {
      url: event_stream_url,
      eventName: event_stream_name(params[:paper_id] || params[:id])
    }
    render json: data.to_json
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).concat %i(first_name last_name affiliation email username)
  end

  private
  def event_stream_name(paper_id)
    Digest::MD5.hexdigest "paper_#{paper_id}"
  end

  def event_stream_token
    ENV["ES_TOKEN"] || "token123" # Digest::MD5.hexdigest("some token")
  end

  def event_stream_url
    ENV["ES_URL"] || "http://localhost:8080/stream?token=#{event_stream_token}"
  end

  def event_stream_update_url
    ENV["ES_UPDATE_URL"] || "http://localhost:8080/update_stream"
  end

  def verify_admin!
    redirect_to(root_path, alert: "Permission denied") unless current_user.admin?
  end

  def render_errors(e)
    render status: 400, json: {errors: e.record.errors}
  end
end
