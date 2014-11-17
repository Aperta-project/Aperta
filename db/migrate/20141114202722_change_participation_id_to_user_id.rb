class ChangeParticipationIdToUserId < ActiveRecord::Migration
  def change
    rename_column :participations, :participant_id, :user_id
  end
end
