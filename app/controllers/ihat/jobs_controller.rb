module Ihat
  class JobsController < ApplicationController
    skip_before_action :authenticate_with_basic_http
    protect_from_forgery with: :null_session
    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :render_invalid_params
    rescue_from ActionController::ParameterMissing, with: :render_invalid_params

    def create
      state = safe_params["state"]
      paper_id = safe_params["options"]["metadata"]["paper_id"]
      paper = Paper.find_by(id: paper_id)
      paper.file.update(status: state) if state.eql? "errored"
      PaperUpdateWorker.perform_async(safe_params)
      head :ok
    end

    private

    def safe_params
      params.require(:job).permit(:id, :state, outputs: [:file_type, :url], options: [:callback_url, :metadata, :recipe_name]).tap do |safe|
        safe[:options][:metadata] = Verifier.new(safe[:options][:metadata]).decrypt
      end
    end

    def render_invalid_params(e)
      render status: :unprocessable_entity, json: { error: e.message }
    end
  end
end
