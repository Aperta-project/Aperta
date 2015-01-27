class IhatJobsController < ApplicationController
  skip_before_action :authenticate_with_basic_http
  protect_from_forgery with: :null_session
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :render_invalid_params

  def update
    if job.completed?
      PaperUpdateWorker.perform_async(job.paper_id, job.epub_url)
      head :ok
    else
      head :accepted
    end
  end

  private

  def job
    @job ||= IhatJobResponse.new(ihat_job_params)
  end

  def ihat_job_params
    params.require(:job).permit(:id, :state, :epub_url).tap do |whitelisted|
      whitelisted[:callback_url] = params[:job][:options][:callback_url]
      whitelisted[:metadata] = params[:job][:options][:metadata]
    end
  end

  def render_invalid_params(e)
    render status: :unprocessable_entity, json: { error: e.message }
  end
end
