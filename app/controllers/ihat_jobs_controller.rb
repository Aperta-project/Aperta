class IhatJobsController < ApplicationController
  skip_before_action :authenticate_with_basic_http
  protect_from_forgery with: :null_session
  rescue_from ActionController::ParameterMissing, with: :render_invalid_params

  def update
    if job.converted?
      PaperUpdateWorker.perform_async(job.paper_id, job.epub_url)
      head :ok
    else
      head :accepted
    end
  end

  private

  def job
    @job ||= IHatJob.new(ihat_job_params)
  end

  def ihat_job_params
    params.require(:job).permit(:id, :state, :url, metadata: :paper_id)
  end

  def render_invalid_params(e)
    render status: :unprocessable_entity, json: { error: e.message }
  end
end
