class ChangeMessageParticipantsToParticipations < ActiveRecord::Migration
  def change
    rename_table :message_participants, :participations
  end
end
