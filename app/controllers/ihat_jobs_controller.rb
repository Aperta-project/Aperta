class IhatJobsController < ApplicationController
  def update
    job = IhatJob.find_by(job_id: params[:id])
    PaperUpdateWorker.perform_async(job_id: params[:id])
    head 200
  end
end
