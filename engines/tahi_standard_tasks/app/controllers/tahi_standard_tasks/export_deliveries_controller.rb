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
      ExportService.delay(retry: false)
        .make_delivery(export_delivery_id: export_delivery.id)

      render json: export_delivery
    end

    def show
      requires_user_can(:send_to_apex, export_delivery.paper)
      render json: export_delivery
    end

    private

    def delivery_params
      @delivery_params ||= params.require(:export_delivery).permit(:task_id, :destination)
    end

    def task
      Task.find(delivery_params[:task_id])
    end

    def export_delivery
      @export_delivery ||=
        if params[:id]
          ExportDelivery.includes(:user, :paper, :task).find(params[:id])
        else
          ExportDelivery.create!(
            destination: delivery_params[:destination] || 'apex',
            paper: task.paper,
            task: task,
            user: current_user
          )
        end
    end
  end
end
