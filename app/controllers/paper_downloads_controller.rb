# Controller for downloading papers
#
# In the future this can be expanded to handle async processing jobs, but for
# now, everything is returned synchronously.
class PaperDownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    requires_user_can(:view, paper)
    converter = PaperConverter.new(versioned_text, export_format)
    render status: :ok, json: { url: converter.download_url }
  end

  private

  def export_format
    params.require(:export_format)
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params.require(:id))
  end

  def versioned_text_id_param
    params[:versioned_text_id]
  end

  def versioned_text
    @versioned_text ||= begin
      if versioned_text_id_param
        VersionedText.find_by!(
          id: versioned_text_id_param,
          paper: paper
        )
      else
        paper.latest_version
      end
    end
  end
end
