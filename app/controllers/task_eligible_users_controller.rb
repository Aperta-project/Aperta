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

# TaskEligibleUsersController scopes user searches to those who
# are eligible perform appropriate roles for the given task.
# It also requires that users can edit the task before serving
# anything.
#
class TaskEligibleUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def academic_editors
    requires_user_can(:edit, task)
    requires_user_can(:search_academic_editors, task.paper)
    eligible_users = EligibleUserService.eligible_users_for(
      paper: task.paper,
      role: task.paper.journal.academic_editor_role,
      matching: params[:query]
    )
    respond_with(
      find_uninvited_users(eligible_users, task.paper),
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  def admins
    requires_user_can(:edit, task)
    requires_user_can(:search_admins, task.paper)
    eligible_users = EligibleUserService.eligible_users_for(
      paper: task.paper,
      role: task.paper.journal.staff_admin_role,
      matching: params[:query]
    )
    respond_with(
      find_uninvited_users(eligible_users, task.paper),
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  def reviewers
    requires_user_can(:edit, task)
    requires_user_can(:search_reviewers, task.paper)
    users = User.fuzzy_search params[:query]
    respond_with(
      find_uninvited_users(users, task.paper),
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  private

  # NOTE: Invitation.find_uninvited_users will remove users who have
  # any kind of invitation for the paper, not just an invite for the
  # relevant role that the user is currently searching for
  def find_uninvited_users(users, paper)
    Invitation.find_uninvited_users_for_paper(users, paper)
  end

  def task
    @task ||= Task.where(id: params[:task_id]).includes(:paper).first!
  end
end
