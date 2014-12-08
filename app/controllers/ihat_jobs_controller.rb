class IhatJobsController < ApplicationController
  skip_before_action :authenticate_with_basic_http
  protect_from_forgery with: :null_session
  rescue_from ActionController::ParameterMissing, with: :render_invalid_params

  # removing any access check since the next pivotal card will be addressing this
  # include RestrictAccess

  def update
    if job_state == "converted"
      validate_required_params!
      PaperUpdateWorker.perform_async(paper_id, epub_url)
      head :ok
    else
      head :accepted
    end
  end

  private

  def ihat_job_params
    params.require(:job).permit(:id, :state, :url, metadata: :paper_id)
  end

  def paper_id
    ihat_job_params[:metadata][:paper_id]
  end

  def epub_url
    ihat_job_params[:url]
  end

  def job_state
    ihat_job_params[:state]
  end

  def validate_required_params!
    unless [paper_id, epub_url].all?(&:present?)
      raise ActionController::ParameterMissing.new("iHat job id #{ihat_job_params[:id]} did not return required parameters")
    end
  end

  def render_invalid_params(e)
    render status: :unprocessable_entity, json: { error: e.message }
  end
end
