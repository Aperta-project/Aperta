# TaskTemplate gets consumed by the PaperFactory to create a task
# when a paper is first created
class TaskTemplate < ActiveRecord::Base
  include Configurable

  belongs_to :phase_template, inverse_of: :task_templates
  belongs_to :journal_task_type
  belongs_to :card

  has_one :manuscript_manager_template, through: :phase_template
  has_one :journal, through: :manuscript_manager_template

  validates :title, presence: true
  validate :only_one_mold

  acts_as_list scope: :phase_template

  # registered_settings_key is defined in Configurable
  def registered_settings_key
    if journal_task_type
      "TaskTemplate:#{journal_task_type.kind}"
    else
      "TaskTemplate:#{card.name}"
    end
  end

  private

  # This validation enforces the decision point between the "old world" of
  # TaskTemplates being associated to a JournalTaskType and the new "card
  # config world" of being associated to a Card.  You cannot have feet in
  # both worlds.
  def only_one_mold
    unless [journal_task_type_id, card_id].one?
      errors.add(:base,
                 'must be associated with only one Journal Task Type or Card')
    end
  end
end
