# Controller for conversions that might need to happen in the
# background.
#
# Javascript code will call /papers/ID/export.FORMAT, which returns
# 202 and the body { url: ... }, which is a status URL.
#
# The status URL will return 202 while the conversion is still
# processing, 500 if the processing failed or 200 and the body { url:
# ... } when it is done, where URL will be a URL that can be
# downloaded.
#
# This somewhat complicated mechanism allows for background
# processing, but will also work for content that does not need
# background processing.
class PaperConversionsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: :status

  # Returns 202 and a url to check for status.
  def export
    @export_format = params[:format]
    job_id = if params[:format] == 'docx' &&
                paper.latest_version.source_url.present?
               # This is already available for download, and does not
               # need background processing.
               'source'
             else
               PaperConverter.export(paper, @export_format, current_user).job_id
             end
    render json: { url: url_for(controller: :paper_conversions, action: :status,
                                id: params[:id], job_id: job_id,
                                export_format: 'docx') },
           status: :accepted
  end

  # Check the status of a job.
  # If done, return a 200 and a download url.
  # If errored, return 500.
  # If pending, return 202.
  def status
    if params[:job_id] == 'source'
      # Direct download, redirect to download link.
      render status: :ok, json: { url: paper.latest_version.source_url }
    else
      job = PaperConverter.check_status(params[:job_id])
      if job.completed?
        render status: :ok, json: {
          url: job.format_url(params[:export_format]) }
      elsif job.errored?
        render status: :server_error, nothing: true
      else
        render status: :accepted, nothing: true
      end
    end
  end

  private

  def enforce_policy
    authorize_action!(resource: paper)
  end

  def paper
    @paper ||= Paper.find(params[:id])
  end
end
