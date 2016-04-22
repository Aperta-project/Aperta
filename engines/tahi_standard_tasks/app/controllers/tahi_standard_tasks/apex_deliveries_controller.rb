module TahiStandardTasks
  #
  # Endpoints for the ApexDelivery task. See ApexDelivery and SendToApexTask for
  # more details.
  #
  class ApexDeliveriesController < ::ApplicationController
    before_action :authenticate_user!

    respond_to :json

    def create
      requires_user_can(:send_to_apex, task.paper)
      ApexService.delay(retry: false)
        .make_delivery(apex_delivery_id: apex_delivery.id)

      render json: apex_delivery
    end

    def show
      requires_user_can(:send_to_apex, apex_delivery.paper)
      render json: apex_delivery
    end

    private

    def delivery_params
      @delivery_params ||= params.require(:apex_delivery).permit(:task_id)
    end

    def task
      Task.find(delivery_params[:task_id])
    end

    def apex_delivery
      @apex_delivery ||=
        if params[:id]
          ApexDelivery.includes(:user, :paper, :task).find(params[:id])
        else
          ApexDelivery.create!(
            paper: task.paper,
            task: task,
            user: current_user)
        end
    end
  end
end
