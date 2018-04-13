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

class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    permitted = params.require(:scheduled_event).permit(:state)
    scheduled_event = ScheduledEvent.find(params[:id])
    owner = scheduled_event.due_datetime.due
    # Ideally this would be a relationship directly on a task, le sigh
    requires_user_can(:edit, (owner.is_a?(Task) ? owner : owner.task))
    scheduled_event.switch_on! if permitted[:state] == 'active'
    scheduled_event.switch_off! if permitted[:state] == 'passive'
    render json: scheduled_event
  end
end
