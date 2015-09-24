class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  before_action :enforce_index_policy, only: [:index]
  respond_to :json

  def index
    respond_with(Question.includes(:task, :question_attachment).
                  where(task_id: params[:task_id]), root: :questions)
  end

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
    params.require(:question).permit(:ident, :task_id, :decision_id, :question, :answer, :url).tap do |whitelisted|
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
      else
        Question.new question_params.except(:url)
      end
  end

  def has_attachment?
    question_params[:url].present?
  end

  def enforce_policy
    authorize_action!(question: question)
  end

  def enforce_index_policy
    authorize_action!(question: nil, for_task: Task.find(params[:task_id]))
  end
end
