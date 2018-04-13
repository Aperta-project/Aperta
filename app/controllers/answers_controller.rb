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

# CRUD on Answer
class AnswersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  # return all answers for a given `owner` (e.g., `AdHocTask`)
  # when answers are loaded as a group dont include the ready and ready issues
  # look at task#update in the task_controller and the TaskAnswerSerializer
  # to see when ready and ready issues are side loaded with a task and answers

  def index
    requires_user_can(:view, owner)
    respond_with owner.answers, except: [:ready, :ready_issues]
  end

  def create
    requires_user_can(:edit, owner)
    answer = Answer.create(answer_params.merge(paper: owner.paper))
    respond_with answer
  end

  def show
    answer = Answer.find(params[:id])
    requires_user_can_view(answer)

    render json: answer, serializer: LightAnswerSerializer, root: 'answer'
  end

  def update
    answer = Answer.find(params[:id])
    requires_user_can(:edit, answer.owner)
    answer.update!(answer_params)
    render json: answer, serializer: LightAnswerSerializer, root: 'answer'
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
                                   :annotation,
                                   :card_content_id,
                                   :repetition_id)
  end
end
