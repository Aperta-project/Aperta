class RenameActivityFeedsToActivities < ActiveRecord::Migration
  def change
    rename_table :activity_feeds, :activities
  end
end
