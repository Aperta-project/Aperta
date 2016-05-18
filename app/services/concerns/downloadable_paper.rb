require 'render_anywhere'

class DownloadablePaperController < RenderAnywhere::RenderingController; end

# included in classes that create downloadable papers in various formats
module DownloadablePaper
  include RenderAnywhere

  def paper_body
    return 'The manuscript is currently empty.' if @paper.figureful_text.blank?
    body_with_aws_figure_urls.html_safe
  end

  # filename appropriate for a filesystem
  # handles size and bad chars
  def fs_filename
    filename = @paper.display_title.gsub(/[^)(\d\w\s_-]+/, '')
    filename = filename[0..149] # limit to 150 chars
    "#{filename}.#{document_type}"
  end

  def document_type
    # :pdf, :epub
    self.class.to_s.underscore.split('_').first.to_sym
  end

  def rendering_controller
    @rendering_controller ||= DownloadablePaperController.new
  end

  private

  def body_with_aws_figure_urls
    @paper.figureful_text(direct_img_links: true)
  end
end
