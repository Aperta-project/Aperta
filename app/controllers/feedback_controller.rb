class FeedbackController < ApplicationController
  def create
    email_to = ENV['ADMIN_EMAIL']
    Feedback.new(user: current_user,
                 email_to: email_to,
                 feedback: params[:feedback][:remarks],
                 referrer: params[:feedback][:referrer],
                 env: Rails.env).deliver

    render json: {}, status: :created
  end
end
