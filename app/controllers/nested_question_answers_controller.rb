class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_able_to_edit_task
  respond_to :json

  def create
    answer = fetch_and_update_answer
    render json: answer, serializer: AnswerAsNestedQuestionAnswerSerializer
  end

  def update
    answer = fetch_and_update_answer
    render json: answer, serializer: AnswerAsNestedQuestionAnswerSerializer
  end

  def destroy
    answer = fetch_answer
    answer.destroy
    respond_with answer
  end

  private

  def fetch_and_update_answer
    answer = fetch_or_create_answer
    answer.value = answer_params[:value]
    answer.additional_data = answer_params[:additional_data]
    answer.save!
    answer
  end

  def fetch_answer
    @answer ||= if params[:id]
                  Answer.find(params[:id])
                else
                  card_content
                    .answers.where(owner: owner, paper: owner.paper).first
                end
  end

  def fetch_or_create_answer
    return fetch_answer if fetch_answer
    @answer ||= card_content.answers.create(owner: owner, paper: owner.paper)
  end

  def owner
    @owner ||= owner_type.find(answer_params[:owner_id])
  end

  def owner_type
    LookupOwnerType.lookup(answer_params[:owner_type])
  end

  def card_content
    @card_content ||= begin
                        card_content_id = params.permit(:nested_question_id)
                                                .fetch(:nested_question_id)
                        CardContent.find(card_content_id)
                      end
  end

  def answer_params
    @answer_params ||= params
                       .require(:nested_question_answer)
                       .permit(:owner_id, :owner_type, :value, :decision_id)
                       .tap do |whitelisted|
      whitelisted[:additional_data] = \
        params[:nested_question_answer][:additional_data]
    end
  end

  def must_be_able_to_edit_task
    if owner.is_a? Task
      raise AuthorizationError unless current_user.can?(:edit, owner)
    else
      raise AuthorizationError unless current_user.can?(:edit, owner.task)
    end
  end
end
