module Ihat
  class JobsController < ApplicationController
    skip_before_action :authenticate_with_basic_http
    protect_from_forgery with: :null_session
    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :render_invalid_params
    rescue_from ActionController::ParameterMissing, with: :render_invalid_params

    def create
      if file_type == 'pdf'
        # This is where we can put in a worker specific to pdfs to process any pdf epubs
        response = IhatJobResponse.new(safe_params)
        Notifier.notify(event: "paper:data_extracted", data: { record: response })
      else
        PaperUpdateWorker.perform_async(safe_params)
      end
      head :ok
    end

    private

    def file_type
      safe_params[:outputs].first[:file_type]
    end

    def safe_params
      params_safe =
        params.require(:job).permit(:id, :state, outputs: [:file_type, :url], options: [:callback_url, :metadata])
      params_safe[:options][:metadata] = Verifier.new(params_safe[:options][:metadata]).decrypt
      params_safe
    end

    def render_invalid_params(e)
      render status: :unprocessable_entity, json: { error: e.message }
    end
  end
end
