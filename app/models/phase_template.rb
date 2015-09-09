class PhaseTemplate < ActiveRecord::Base
  belongs_to :manuscript_manager_template, inverse_of: :phase_templates
  has_many :task_templates, -> { order("position asc") },
                                inverse_of: :phase_template,
                                dependent: :destroy

  has_one :journal, through: :manuscript_manager_template

  validates :name, uniqueness: { scope: :manuscript_manager_template_id }

  acts_as_list scope: :manuscript_manager_template
end
