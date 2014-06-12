class QuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    task = Task.find(question_params[:task_id])
    question = task.questions.new(question_params)
    authorize_action!(question: question)
    question.save
    respond_with question
  end

  def update
    question = Question.find(params[:id])
    authorize_action!(question: question)
    question.update_attributes(question_params)
    respond_with question
  end

  private

  def question_params
    params.require(:question).permit(:ident, :task_id, :question, :answer).tap do |whitelisted|
      whitelisted[:additional_data] = params[:question][:additional_data]
    end
  end
end
