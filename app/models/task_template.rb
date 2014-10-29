class TaskTemplate < ActiveRecord::Base
  belongs_to :phase_template, inverse_of: :task_templates
  belongs_to :journal_task_type

  has_one :manuscript_manager_template, through: :phase_template
  has_one :journal, through: :manuscript_manager_template

  validates :title, presence: true
  delegate :role, to: :journal_task_type
end
