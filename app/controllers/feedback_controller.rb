class FeedbackController < ApplicationController
  def create
    feedback = params[:feedback]

    Feedback.new(user: current_user,
                 screenshots: feedback[:screenshots] || [],
                 feedback: feedback[:remarks],
                 referrer: feedback[:referrer]).deliver

    render json: {}, status: :created
  end
end
