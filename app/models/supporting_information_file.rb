# Supporting Information includes Figures, Data, and other Files that help in
# understanding the manuscript, but are not central to the scientific argument.
# They are often linked to, but not typically embedded in the document.
class SupportingInformationFile < Attachment
  self.public_resource = true

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  validates :category, presence: true, if: :task_completed?

  validates :status, acceptance: { accept: STATUS_DONE }, if: :task_completed?

  before_create :set_publishable

  def alt
    if file.present?
      regex = /#{::File.extname(filename)}$/
      filename.split('.').first.gsub(regex, '').humanize
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

  protected

  def build_title
    title
  end
end
