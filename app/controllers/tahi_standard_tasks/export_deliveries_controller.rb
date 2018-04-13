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

module TahiStandardTasks
  #
  # Endpoints for the ExportDelivery task. See ExportDelivery and SendToApexTask for
  # more details.
  #
  class ExportDeliveriesController < ::ApplicationController
    before_action :authenticate_user!

    respond_to :json

    def create
      requires_user_can(:send_to_apex, task.paper)
      export_delivery = ExportDelivery.create!(
        destination: delivery_params[:destination] || 'apex',
        paper: task.paper,
        task: task,
        user: current_user
      )
      ExportService.delay(retry: false)
        .make_delivery(export_delivery_id: export_delivery.id)

      render json: export_delivery
    end

    def show
      export_delivery = ExportDelivery.includes(:user, :paper, :task).find(params[:id])
      requires_user_can_view(export_delivery)
      render json: export_delivery
    end

    private

    def delivery_params
      @delivery_params ||= params.require(:export_delivery).permit(:task_id, :destination)
    end

    def task
      Task.find(delivery_params[:task_id])
    end
  end
end
