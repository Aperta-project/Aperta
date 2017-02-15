class AnswersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  # return all answers for a given `owner` (i.e., `CoverLetterTask`)
  def index
    respond_with owner_klass.find(params[:owner_id]).answers
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

  def owner_klass
    raw_owner_type = (params[:owner_type] || answer_params[:owner_type])
    potential_owner_name = raw_owner_type.classify
    potential_owner = potential_owner_name.constantize
    assert(potential_owner.try(:answerable?), "resource is not answerable")

    potential_owner
  end

  def owner
    @owner ||= owner_klass.find(answer_params[:owner_id])
  end

  def answer_params
    params.require(:answer).permit(:owner_type, :owner_id, :value, :card_content_id)
  end
end
