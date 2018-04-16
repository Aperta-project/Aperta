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

class RepetitionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:view, task)
    respond_with task.repetitions
  end

  def create
    requires_user_can(:edit, task)
    repetition = Repetition.create(repetition_params)
    render json: repetition_positions(first: repetition)
  end

  def update
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    repetition.update(repetition_params)
    render json: repetition_positions(first: repetition)
  end

  def destroy
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    repetition.destroy

    if params[:destroying_all]
      # client has reported that all repetitions are being destroyed
      # and does not care about returning a position for reordering
      head :no_content
    else
      render json: repetition_positions(first: repetition)
    end
  end

  private

  def task
    @task ||= Task.find(params[:task_id] || repetition_params[:task_id])
  end

  def card_content
    @card_content ||= CardContent.find(repetition_params[:card_content_id])
  end

  def repetition_params
    params.require(:repetition).permit(
      :card_content_id,
      :task_id,
      :parent_id,
      :position
    )
  end

  # Return an array of sibling repetitions so that positions can be returned to
  # the client.  Ember expects that when returning an array for a single object
  # action (create / update), the first object must be the one that
  # was modified.  In the case of destroy, do not return the deleted model.
  def repetition_positions(first:)
    rest = Repetition.where(parent_id: first.parent_id, card_content: first.card_content, task: first.task)
                     .where.not(id: first.id)

    if first.destroyed?
      rest
    else
      [first] + rest
    end
  end
end
