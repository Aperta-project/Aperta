# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# A Figure is an image the author provides, that is included as part of the
# manuscript, to elucidate upon the point they are trying to make. Figures are
# typically graphs, charts, or other scientific extrapolations of data.
class Figure < Attachment
  self.public_resource = true

  default_scope { order(:id) }

  after_save :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  delegate_view_permission_to :paper

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

  def filename
    # pending_url holds the actual URI encoded filename, Carrierwave mangles it something awful
    pending_url ? URI.decode(pending_url.split('/').last.tr('+', ' ')) : super
  end

  protected

  def build_title
    return title if title.present?
    title_from_filename || 'Unlabeled'
  end

  private

  def title_from_filename
    title_rank_regex = /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
    title_rank_regex.match(filename) do |match|
      return "Fig #{match['label']}"
    end
  end

  def should_insert_figures?
    title_changed? && !downloading? && all_figures_done? && resource_token
  end

  def all_figures_done?
    paper.figures.all?(&:done?)
  end
end
