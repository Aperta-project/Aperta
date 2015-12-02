module TahiStandardTasks
  #
  # Endpoints for the ApexDelivery task. See ApexDelivery and SendToApexTask for
  # more details.
  #
  class ApexDeliveriesController < ::ApplicationController
    # before_action :authenticate_user!
    # before_action :enforce_policy
    respond_to :json

    def create
      apex_delivery = ApexDelivery.create!(
        paper: task.paper,
        task: task,
        user: current_user)

      ApexService.delay(retry: false)
        .make_delivery(apex_delivery_id: apex_delivery.id)

      render json: apex_delivery
    end

    def show
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
      ApexDelivery.find(params[:id])
    end

    def enforce_policy
      authorize_action!(resource: apex_delivery)
    end
  end
end
