class NestedQuestionsController < ApplicationController
  def index
    owner_type = NestedQuestion.lookup_owner_type(params[:type])
    nested_questions = NestedQuestion.where(owner_type: owner_type, owner_id:nil)
    render json: nested_questions
  end
end
