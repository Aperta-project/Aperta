# A Figure is an image the author provides, that is included as part of the
# manuscript, to elucidate upon the point they are trying to make. Figures are
# typically graphs, charts, or other scientific extrapolations of data.
class Figure < Attachment
  include CanBeStrikingImage

  default_scope { order(:id) }

  mount_uploader :file, AttachmentUploader

  after_save :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize if filename.present?
  end

  def src
    non_expiring_proxy_url if done?
  end

  def detail_src(**opts)
    non_expiring_proxy_url(version: :detail, **opts) if done?
  end

  def preview_src
    non_expiring_proxy_url(version: :preview) if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def rank
    return unless title
    number_match = title.match /\d+/
    number_match[0].to_i if number_match
  end

  private

  def should_insert_figures?
    (title_changed? || file_changed?) && all_figures_done?
  end

  def all_figures_done?
    paper.figures.all?(&:done?)
  end
end
