# Supporting Information includes Figures, Data, and other Files that help in
# understanding the manuscript, but are not central to the scientific argument.
# They are often linked to, but not typically embedded in the document.
class SupportingInformationFile < Attachment
  include CanBeStrikingImage

  before_save :ensure_striking_image_category_is_figure

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  validates :category, :title, presence: true, if: :task_completed?

  before_create :set_publishable

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

  private

  # Default to true if unset
  def set_publishable
    self.publishable = true if publishable.nil?
  end

  def task_completed?
    task && task.completed?
  end
end
