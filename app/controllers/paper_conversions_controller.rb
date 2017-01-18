# Controller for conversions that might need to happen in the
# background.
#
# Javascript code will call /papers/ID/export?export_format=FORMAT,
# which returns 202 and the body { url: ... }, which is a status URL.
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

  # Returns 202 and a url to check for status.
  def export
    requires_user_can(:view, paper)

    job_id = 'source'

    render json: { url: url_for(controller: :paper_conversions, action: :status,
                                id: params[:id], job_id: job_id,
                                export_format: export_format) },
    status: :accepted
  end

  # Check the status of a job.
  # If done, return a 200 and a download url.
  # If errored, return 500.
  # If pending, return 202.
  # Historical Note:
  # This was written when docx was being converted from user-edited html
  # This is now not happening but rather we are linking directly to the
  # original docx file. This method should probably be updated to reflect
  # that. That may mean that the entire controller is unnecessary.
  def status
    requires_user_can(:view, paper)
    if params[:job_id] == 'source'
      # Direct download, redirect to download link.
      render status: :ok, json: { url: paper.file.url }
    else
      job = PaperConverter.check_status(params[:job_id])
      if job.completed?
        render status: :ok, json: {
          url: job.format_url(export_format) }
      elsif job.errored?
        render status: :server_error, nothing: true
      else
        render status: :accepted, nothing: true
      end
    end
  end

  private

  def export_format
    export_format ||= params[:export_format]
  end

  def doc_file_type_and_doc_attached
    export_format == 'doc' && paper.file_type == 'doc' && paper.file.url.present?
  end

  def docx_file_type_and_docx_attached
    export_format == 'docx' && paper.file_type == 'docx' && paper.file.url.present?
  end

  def pdf_file_type_and_pdf_attached
    export_format == 'pdf' && paper.file_type == 'pdf' && paper.file.url.present?
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:id])
  end
end
