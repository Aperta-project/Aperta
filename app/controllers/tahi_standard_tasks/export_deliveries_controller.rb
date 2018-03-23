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
