class Figure < ActiveRecord::Base
  include EventStream::Notifiable
  include CanBeStrikingImage
  include ProxyableResource

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :paper

  default_scope { order(:id) }

  mount_uploader :attachment, AttachmentUploader

  after_update :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def filename
    self[:attachment]
  end

  # This is a hash used for recognizing changes in file contents; if
  # the file doens't exist, or if we can't connect to amazon, minimal
  # harm comes from returning nil instead. The error thrown is,
  # unfortunately, not wrapped by carrierwave.
  def file_hash
    attachment.file.attributes[:etag]
  rescue
    nil
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

  def should_insert_figures?
    title_changed? || attachment_changed?
  end

  def rank
    return unless title
    number_match = title.match /\d+/
    number_match[0].to_i if number_match
  end

  private

  def done?
    status == 'done'
  end
end
