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

# Decisions Controller
class DecisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_paper_and_verdict!, only: [:register]
  respond_to :json

  def index
    paper = Paper.find_by_id_or_short_doi(params[:paper_id])
    requires_user_can(:view, paper)

    decisions = if current_user.can?(:view_decisions, paper)
                  paper.decisions
                else
                  paper.decisions.completed
                end

    render json: decisions.includes(invitations: [:task,
                                                  :invitee,
                                                  :primary,
                                                  :alternates,
                                                  :invitation_queue,
                                                  :attachments]),
           each_serializer: DecisionSerializer,
           root: 'decisions'
  end

  def show
    paper = decision.paper
    revise_task = paper.revise_task
    if revise_task.present? && !revise_task.completed?
      requires_user_can_view(revise_task)
    else
      requires_user_can(:view_decisions, paper)
    end
    render json: decision,
           serializer: DecisionSerializer, root: 'decision'
  end

  def update
    permitted = []
    revise_task = decision.paper.last_of_task(TahiStandardTasks::ReviseTask)
    if current_user.can?(:register_decision, decision.paper)
      permitted += [:verdict, :letter]
    end
    if !revise_task.nil? && current_user.can?(:edit, revise_task)
      # Only allow the creator to update the `author_response` column
      permitted += [:author_response]
    end
    raise AuthorizationError if permitted.empty?
    decision.update! params.require(:decision).permit(*permitted)
    head :no_content
  end

  def register # I expect a task_id param, too!
    requires_user_can(:register_decision, decision.paper)

    task = Task.find(params[:task_id])
    # These lines let us update the task/paper in the requester's browser
    # without having to serialize the task along with the decision
    decision.register!(task)

    task.send_email

    Activity.decision_made! decision, user: current_user

    render json: decision.paper.decisions,
           each_serializer: DecisionSerializer,
           root: 'decisions'
  end

  def rescind
    requires_user_can(:rescind_decision, decision.paper)
    assert decision.rescindable?, "That decision is not rescindable"

    decision.rescind!

    Activity.decision_rescinded! decision, user: current_user

    render json: decision.paper.decisions,
           each_serializer: DecisionSerializer,
           root: 'decisions'
  end

  private

  def decision
    @decision ||= Decision.includes(:paper).find(params[:id])
  end

  def verify_paper_and_verdict!
    assert decision.verdict.present?, "You must pick a verdict, first"
    assert decision.paper.awaiting_decision?, "The paper must be submitted"
  end
end
