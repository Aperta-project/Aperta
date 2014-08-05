class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    if question.save
      process_attachment(question)
    end
    respond_with question
  end

  def update
    if question.update_attributes(question_params.except(:url))
      process_attachment(question)
    end
    render json: question
  end

  private

  def question_params
    params.require(:question).permit(:ident, :task_id, :question, :answer, :url).tap do |whitelisted|
      whitelisted[:additional_data] = params[:question][:additional_data]
    end
  end

  def process_attachment(question)
    if has_attachment?
      question_attachment = question.question_attachment || question.build_question_attachment
      question_attachment.update_attribute :status, "processing"
      DownloadQuestionAttachmentWorker.perform_async question_attachment.id, question_params[:url]
    end
  end

  def question
    @question ||=
      if params[:id]
        Question.find(params[:id])
      elsif question_params[:task_id]
        task = Task.find(question_params[:task_id])
        task.questions.new(question_params.except(:url))
      end
  end

  def has_attachment?
    question_params[:url].present?
  end

  def enforce_policy
    authorize_action!(question: question)
  end
end
