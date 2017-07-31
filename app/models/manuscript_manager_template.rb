class ManuscriptManagerTemplate < ActiveRecord::Base
  include Configurable
  belongs_to :journal, inverse_of: :manuscript_manager_templates
  has_many :phase_templates, -> { order("position asc") },
                                inverse_of: :manuscript_manager_template,
                                dependent: :destroy

  validates :paper_type, presence: true
  validates :paper_type, uniqueness: { scope: :journal_id,
                                       case_sensitive: false }

  def papers
    journal.papers.where(paper_type: paper_type)
  end

  def review_duration_period
    setting('review_duration_period').value
  end

  def setting_template_key
    "ManuscriptManagerTemplate"
  end
end
