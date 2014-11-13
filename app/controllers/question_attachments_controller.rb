class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def destroy
    question_attachment.destroy
    respond_with question_attachment
  end

  private

  def question_attachment
    @question_attachment ||= QuestionAttachment.find(params[:id])
  end

  def enforce_policy
    authorize_action!(question_attachment: question_attachment)
  end
end
