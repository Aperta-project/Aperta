# CRUD on Answer
class AnswersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  # return all answers for a given `owner` (i.e., `CoverLetterTask`)
  def index
    requires_user_can(:view, owner)
    respond_with owner.answers
  end

  def create
    requires_user_can(:edit, owner)
    answer = Answer.create(answer_params.merge(paper: owner.paper))
    respond_with answer
  end

  def update
    answers = Answer.where(owner: owner)
    related_answer = answers.find(params[:id])
    requires_user_can(:edit, related_answer.owner)
    related_answer.update!(answer_params)
    render json: answers, each_serializer: LightAnswerSerializer
  end

  def destroy
    answer = Answer.find(params[:id])
    requires_user_can(:edit, answer.owner)
    respond_with answer.destroy
  end

  private

  # since `index` action doesn't work with the `answer_params`
  # the owner type could come from two possible places, and
  # `raw_owner_type` is where we account for it.
  def raw_owner_type
    params[:owner_type] || answer_params[:owner_type]
  end

  def owner_klass
    potential_owner = raw_owner_type.classify.constantize
    assert(potential_owner.try(:answerable?), "resource is not answerable")

    potential_owner
  end

  def owner_id
    params[:owner_id] || answer_params[:owner_id]
  end

  def owner
    @owner ||= owner_klass.find(owner_id)
  end

  def answer_params
    params.require(:answer).permit(:owner_type,
                                   :owner_id,
                                   :value,
                                   :card_content_id)
  end
end
