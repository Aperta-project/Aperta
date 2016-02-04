##
# Moving the spearated Bio tasks into a single engine and a single module.
# this requires migrating their types in the DB.
#
class RenamePlosBioTasks < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE tasks SET type = 'PlosBio::InitialTechCheckTask'
                   WHERE type = 'PlosBioTechCheck::InitialTechCheckTask';

      UPDATE tasks SET type = 'PlosBio::RevisionTechCheckTask'
                   WHERE type = 'PlosBioTechCheck::RevisionTechCheckTask';

      UPDATE tasks SET type = 'PlosBio::FinalTechCheckTask'
                   WHERE type = 'PlosBioTechCheck::FinalTechCheckTask';

      UPDATE tasks SET type = 'PlosBio::EditorsDiscussionTask'
                   WHERE type = 'PlosBioInternalReview::EditorsDiscussionTask';
    SQL
  end
end
