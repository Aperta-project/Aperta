class AnswersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  # return all answers for a given `owner` (i.e., `CoverLetterTask`)
  def index
    respond_with owner.answers
  end

  def create
    answer = Answer.create(answer_params.merge(paper: owner.paper))
    respond_with answer
  end

  def update
    answer = Answer.find(params[:id]).update_attributes(answer_params)
    respond_with answer
  end

  def destroy
    respond_with Answer.find(params[:id]).destroy
  end

  private

  # since `index` action doesn't work with the `answer_params` the owner type could
  # come from two possible places, and `raw_owner_type` is where we account for it.
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
    params.require(:answer).permit(:owner_type, :owner_id, :value, :card_content_id)
  end
end
