class IhatJobsController < ApplicationController
  skip_before_action :authenticate_with_basic_http
  protect_from_forgery with: :null_session

  include RestrictAccess

  def ihat_callback
    paper_id = params[:state][:paper_id]
    job_id = params[:job_id]
    PaperUpdateWorker.perform_async(paper_id, job_id)
  end
end
