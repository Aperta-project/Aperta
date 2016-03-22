# included in classes that create downloadable papers in various formats
module DownloadablePaper
  def paper_body
    return 'The manuscript is currently empty.' if @paper.body.blank?

    if @paper.figures.any?
      if document_type == :pdf
        return body_with_aws_figure_urls.html_safe
      elsif document_type == :epub
        return body_with_fullpath_proxy_figure_urls.html_safe
      end
    end

    @paper.body.html_safe
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

  def needs_non_redirecting_preview_url?
    [:pdf].include? document_type
  end

  # Return figures that are not present in the document i.e., those lacking a
  # corresponding img#figure_ID element
  def orphan_figures
    doc = Nokogiri::HTML.fragment(@paper.body)
    @paper.figures.select do |figure|
      doc.css("img#figure_#{figure.id}").first.blank?
    end
  end

  private

  def body_with_aws_figure_urls
    @paper.figureful_text(direct_img_links: true)
  end

  def body_with_fullpath_proxy_figure_urls
    Nokogiri::HTML.fragment(@paper.body).tap do |doc|
      @paper.figures.each do |figure|
        img = doc.css("img#figure_#{figure.id}").first
        next unless img
        img.set_attribute 'src', figure.non_expiring_proxy_url(
          version: :detail, only_path: false)
      end
    end.to_s
  end

  def downloadable_templater
    templates_dir = "#{Rails.root}/app/views/downloads/manuscript/"
    ActionView::Base.new(templates_dir)
  end
end
