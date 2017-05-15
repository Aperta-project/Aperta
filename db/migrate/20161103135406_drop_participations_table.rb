# Participations are no longer used
class DropParticipationsTable < ActiveRecord::Migration
  def change
    drop_table :participations
  end
end
