class ManuscriptManagerTemplate < ActiveRecord::Base
  belongs_to :journal, inverse_of: :manuscript_manager_templates
  has_many :phase_templates, -> { order("position asc") },
                                inverse_of: :manuscript_manager_template,
                                dependent: :destroy

  validates :paper_type, presence: true
  validates :paper_type, uniqueness: { scope: :journal_id }

end
