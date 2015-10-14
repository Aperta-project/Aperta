module Ihat
  class JobsController < ApplicationController
    skip_before_action :authenticate_with_basic_http
    protect_from_forgery with: :null_session
    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :render_invalid_params
    rescue_from ActionController::ParameterMissing, with: :render_invalid_params

    def create
      params_safe =
        params.require(:job).permit(:id, :state, outputs: [:file_type, :url], options: [:callback_url, :metadata])
      params_safe[:options][:metadata] = Verifier.new(params_safe[:options][:metadata]).decrypt
      PaperUpdateWorker.perform_async(params_safe)
      head :ok
    end

    private

    def render_invalid_params(e)
      render status: :unprocessable_entity, json: { error: e.message }
    end
  end
end
