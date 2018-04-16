# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# The AssignmentsController is the end-point responsible for managing
# assignments over HTTP.
class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    paper = Paper.find_by_id_or_short_doi(params[:paper_id])
    requires_user_can(:assign_roles, paper)

    render(
      json: paper.assignments,
      each_serializer: AssignmentSerializer,
      root: :assignments
    )
  end

  def create
    paper = Paper.find_by_id_or_short_doi(assignment_params[:paper_id])
    requires_user_can :assign_roles, paper

    role = paper.journal.roles.find(assignment_params[:role_id])
    user = User.find(assignment_params[:user_id])

    assignment = Assignment.where(
      assigned_to: paper,
      role: role,
      user: user
    ).first_or_initialize

    if EligibleUserService.eligible_for?(paper: paper, role: role, user: user)
      assignment.save!
      Activity.assignment_created!(assignment, user: current_user)
      render \
        json: assignment, serializer: AssignmentSerializer, root: :assignment
    else
      render json: paper, status: 422
    end
  end

  def destroy
    assignment = Assignment.find(params[:id])
    requires_user_can :assign_roles, assignment.assigned_to
    assignment.destroy

    Activity.assignment_removed!(assignment, user: current_user)

    render json: assignment, serializer: AssignmentSerializer, root: :assignment
  end

  private

  def assignment_params
    params.require(:assignment).permit(:paper_id, :user_id, :role_id)
  end
end
