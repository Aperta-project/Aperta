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

##
# Controller for due datetime
##
class DueDatetimesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    requires_user_can :edit_due_date, due_datetime.due.task
    due_datetime.update_attributes due_datetime_params
    due_datetime.due.schedule_events
    Activity.due_datetime_updated!(due_datetime, user: current_user)
    render json: due_datetime
  end

  private

  def due_datetime
    @due_datetime ||= DueDatetime.find(params[:id])
  end

  def due_datetime_params
    params.require(:due_datetime).permit(:due_at)
  end
end
