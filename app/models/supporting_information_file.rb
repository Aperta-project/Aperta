# Supporting Information includes Figures, Data, and other Files that help in
# understanding the manuscript, but are not central to the scientific argument.
# They are often linked to, but not typically embedded in the document.
class SupportingInformationFile < Attachment
  include CanBeStrikingImage

  before_save :ensure_striking_image_category_is_figure

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  mount_uploader :file, SupportingInformationFileUploader

  validates :category, :title, presence: true, if: :task_completed?

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  before_create :set_publishable

  def download!(url)
    super(url)
    update_attributes!(
      title: file.filename,
      status: STATUS_DONE
    )
  end

  def ensure_striking_image_category_is_figure
    self.striking_image = false unless category == 'Figure'
    true
  end

  def alt
    if file.present?
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
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
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
