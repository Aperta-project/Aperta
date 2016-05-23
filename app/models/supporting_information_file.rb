class SupportingInformationFile < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource
  include CanBeStrikingImage


  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :paper

  before_save :ensure_striking_image_category_is_figure

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  mount_uploader :attachment, AdhocAttachmentUploader

  validates :category, :title, presence: true, if: :task_completed?

  belongs_to :supporting_information_task,
             class_name: 'TahiStandardTasks::SupportingInformationTask',
             inverse_of: :supporting_information_files,
             foreign_key: :si_task_id

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  def ensure_striking_image_category_is_figure
    self.striking_image = false unless category == 'Figure'
    true
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
    if attachment.present?
      filename.split('.').first.gsub(/#{::File.extname(filename)}$/, '').humanize
    else
      "no attachment"
    end
  end

  def src
    non_expiring_proxy_url if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def detail_src(**opts)
    return unless image?

    non_expiring_proxy_url(version: :detail, **opts) if done?
  end

  def preview_src
    return unless image?

    non_expiring_proxy_url(version: :preview) if done?
  end

  def image?
    if attachment.file
      IMAGE_TYPES.include? attachment.file.extension
    else
      false
    end
  end

  def insert_title
    self.title = "#{attachment.filename}" if attachment.present?
  end

  private

  def done?
    status == 'done'
  end

  def task_completed?
    supporting_information_task && supporting_information_task.completed?
  end
end
