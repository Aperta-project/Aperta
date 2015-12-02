# included in classes that create downloadable papers in various formats
module DownloadablePaper
  def paper_body
    if @paper.body.present?
      paper_body_with_figures.html_safe
    else
      'The manuscript is currently empty.'
    end
  end

  # filename appropriate for a filesystem
  # handles size and bad chars
  def fs_filename(ext:)
    filename = @paper.display_title.gsub(/[^)(\d\w\s_-]+/, '')
    filename = filename[0..149] # limit to 150 chars
    "#{filename}.#{ext}"
  end

  private

  def paper_body_with_figures
    @paper.body.gsub(/\/attachments\/figures\/(\d+)\?version=detail/) do
      # This is theoretically already being done on paper create after Aaron's
      # ticket
      Figure.find($1).attachment.detail.url
    end
  end

  def downloadable_templater
    templates_dir = "#{Rails.root}/app/views/downloads/manuscript/"
    ActionView::Base.new(templates_dir)
  end
end
