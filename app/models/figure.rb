# A Figure is an image the author provides, that is included as part of the
# manuscript, to elucidate upon the point they are trying to make. Figures are
# typically graphs, charts, or other scientific extrapolations of data.
class Figure < Attachment
  include CanBeStrikingImage

  self.public_resource = true

  default_scope { order(:id) }

  after_save :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  # rubocop:disable Style/RegexpLiteral
  def self.acceptable_content_type?(content_type)
    regex = /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i
    !(!(content_type =~ regex))
  end

  def alt
    if filename.present?
      filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize
    end
  end

  def rank
    return 0 unless title_html
    number_match = title_html.match(/\d+/)
    if number_match
      number_match[0].to_i
    else
      0
    end
  end

  def on_download_complete
    insert_figures! if all_figures_done?
  end

  protected

  def build_title_html
    return title_html if title_html.present?
    title_html_from_filename || 'Unlabeled'
  end

  private

  def title_html_from_filename
    title_rank_regex = /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
    title_rank_regex.match(file.filename) do |match|
      return "Fig #{match['label']}"
    end
  end

  def should_insert_figures?
    title_html_changed? && !downloading? && all_figures_done? && resource_token
  end

  def all_figures_done?
    paper.figures.all?(&:done?)
  end
end
