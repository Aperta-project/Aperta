# SupportingInformationFile is a file/resource/artifact intended to supporting
# the manuscript.
class SupportingInformationFile < Attachment
  include CanBeStrikingImage

  before_save :ensure_striking_image_category_is_figure

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  mount_uploader :file, SupportingInformationFileUploader

  validates :category, :title, presence: true, if: :task_completed?

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  before_create :set_publishable

  def ensure_striking_image_category_is_figure
    self.striking_image = false unless category == 'Figure'
    true
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

  # Default to true if unset
  def set_publishable
    if publishable.nil?
      self.publishable = true
    end
  end

  def task_completed?
    task && task.completed?
  end
end
