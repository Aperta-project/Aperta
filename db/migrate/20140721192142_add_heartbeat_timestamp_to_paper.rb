class AddHeartbeatTimestampToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :last_heartbeat_at, :datetime
  end
end
