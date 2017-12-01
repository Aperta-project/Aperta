class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_able_to_edit_task
  respond_to :json

  def create
    answer = fetch_and_update_answer
    render json: answer, serializer: AnswerAsNestedQuestionAnswerSerializer
  end

  def update
    fetch_and_update_answer
    head :no_content, serializer: AnswerAsNestedQuestionAnswerSerializer
  end

  def destroy
    answer = fetch_answer
    answer.destroy
    respond_with answer
  end

  private

  def fetch_and_update_answer
    answer = fetch_or_create_answer
    if admin_edit?
      additional = answer_params[:additional_data] || {}
      additional[:pending_edit] = answer_params[:value]
      answer.additional_data = additional
    else
      answer.value = answer_params[:value]
      answer.additional_data = answer_params[:additional_data]
    end
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
    @owner ||= if params[:nested_question_answer].present?
                 owner_type.find(answer_params[:owner_id])
               else
                 Answer.find(params[:id]).owner
               end
  end

  def owner_type
    LookupClassNamespace.lookup_namespace(answer_params[:owner_type]).constantize
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
    raise AuthorizationError unless current_user.can?(
      :edit,
      fetch_or_create_answer.task
    )
  end

  def admin_edit?
    owner.class == ReviewerReport && owner.active_admin_edit? && current_user.can?(:edit_answers, owner.paper)
  end
end
