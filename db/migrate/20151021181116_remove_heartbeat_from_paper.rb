class RemoveHeartbeatFromPaper < ActiveRecord::Migration
  def change
    remove_column :papers, :last_heartbeat_at, :datetime
  end
end
