class FeedbackController < ApplicationController
  def create
    Feedback.new(user: current_user,
                 feedback: params[:feedback][:remarks],
                 referrer: params[:feedback][:referrer]).deliver

    render json: {}, status: :created
  end
end
