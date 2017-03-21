# In the new world of card config, a TaskTemplate can have an association to a
# Card.  This strikes a parallel to the "old world" where a TaskTemplate is
# associated to a JournalTaskType.  Eventually, once everything becomes a
# customized Card, the JournalTaskType model and its association to
# TaskTemplates will be removed.
class AddCardRelationshipToTaskTemplate < ActiveRecord::Migration
  def change
    add_reference :task_templates, :card, foreign_key: true, index: true
  end
end
