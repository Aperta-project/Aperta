class FeedbackController < ApplicationController
  before_action :authenticate_user!

  def create
    FeedbackMailer.contact(current_user, feedback_params).deliver_later
    render json: {}, status: :created
  end

  private

  def feedback_params
    params.require(:feedback).permit(:remarks, :referrer, screenshots: [])
  end
end
