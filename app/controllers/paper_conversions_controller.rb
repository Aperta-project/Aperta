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

    render json: { url: url_for(controller: :paper_conversions, action: :status,
                                id: params[:id], job_id: 'source',
                                export_format: export_format,
                                versioned_text_id: params[:versioned_text_id]) },
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
      if params[:versioned_text_id].nil?
        render status: :ok, json: { url: paper.file.url }
      else
        ver = VersionedText.find(params[:versioned_text_id])
        # Make sure the client-supplied version number is for the right paper
        if paper.id == ver.paper_id
          url = s3_url(ver)
          render status: :ok, json: { url: url }
        else
          # If the paper's ID doesn't match the VersionedText paper_id, this is
          # probably a hacking attempt, so we'll error with no explicit info.
          render status: 400
        end
      end
    elsif params[:job_id] == 'raw'
      redirect_to s3_url(paper.latest_version)
    else
      job = PaperConverter.check_status(params[:job_id])
      if job.completed?
        render status: :ok, json: {
          url: job.format_url(export_format)
        }
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

  def s3_url(version)
    s3_path = if export_format == 'source'
                version.s3_full_sourcefile_path
              else
                version.s3_full_path
              end
    Attachment.authenticated_url_for_key(s3_path)
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:id])
  end
end
