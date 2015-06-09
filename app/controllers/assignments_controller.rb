class AssignmentsController < ApplicationController
  def index

  end

  def create
    assignment = PaperRole.new(params.require(:assignment).permit(:role, :user_id, :paper_id))
    assignment.save!
    render json: assignment, serializer: AssignmentSerializer
  end
end
