class FeedbackController < ApplicationController
  def create
    feedback = params[:feedback]
    email_to = ENV['ADMIN_EMAIL']
    Feedback.new(user: current_user,
                 email_to: email_to,
                 feedback: feedback[:remarks],
                 referrer: feedback[:referrer],
                 env: Rails.env).deliver

    render json: {}, status: :created
  end
end
