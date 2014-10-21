class IhatJobsController < ApplicationController
  skip_before_action :authenticate_with_basic_http
  protect_from_forgery with: :null_session

  include RestrictAccess

  def update
    job = IhatJob.find_by(job_id: params[:id])
    PaperUpdateWorker.perform_async(params[:id])
    head :ok
  end
end
