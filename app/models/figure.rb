# A Figure is an image the author provides, that is included as part of the
# manuscript, to elucidate upon the point they are trying to make. Figures are
# typically graphs, charts, or other scientific extrapolations of data.
class Figure < Attachment
  include CanBeStrikingImage

  default_scope { order(:id) }

  after_save :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize if filename.present?
  end

  def rank
    return 0 unless title
    number_match = title.match /\d+/
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

  def build_title
    return title if title.present?
    title_from_filename || 'Unlabeled'
  end

  private

  def title_from_filename
    title_rank_regex = /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
    title_rank_regex.match(file.filename) do |match|
      return "Fig. #{match['label']}"
    end
  end

  def should_insert_figures?
    title_changed? && !downloading? && all_figures_done?
  end

  def all_figures_done?
    paper.figures.all?(&:done?)
  end
end
