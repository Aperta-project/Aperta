class IhatJobsController < ApplicationController
  protect_from_forgery with: :null_session

  def update
    job = IhatJob.find_by(job_id: params[:id])
    PaperUpdateWorker.perform_async(job_id: params[:id])
    head :ok
  end
end
