class ManuscriptManagerTemplate < ActiveRecord::Base
  belongs_to :journal, inverse_of: :manuscript_manager_templates
  has_many :phase_templates, -> { order("position asc") },
                                inverse_of: :manuscript_manager_template,
                                dependent: :destroy

  has_many :task_templates, through: :phase_templates

  validates :paper_type, presence: true
  validates :paper_type, uniqueness: { scope: :journal_id,
                                       case_sensitive: false }

  def papers
    journal.papers.where(paper_type: paper_type)
  end

  def task_template_by_kind(kind)
    task_templates.joins(:journal_task_type).find_by(journal_task_types: { kind: kind })
  end
end
