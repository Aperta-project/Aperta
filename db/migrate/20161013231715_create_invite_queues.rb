# Queues keeps track of and hold invitation-like objects
class CreateInviteQueues < ActiveRecord::Migration
  def change
    create_table :invite_queues do |t|
      t.integer :task_id
      t.integer :decision_id
      t.timestamps
    end

    add_column :invitations, :invite_queue_id, :integer
  end
end

# # This data migration ensures that invitations that were associated with tasks
# # are properly associated into queues
# class MigrateInvitationsToQueues < DataMigration
#   RAKE_TASK_UP = 'data:migrate:migrate_invitations_to_queues'.freeze
#   RAKE_TASK_DOWN = 'data:migrate:migrate_queues_back_to_invitations'.freeze
# end
