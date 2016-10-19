# TODO: Make a data migration to go with this once it's actually working
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-5579: Migrates invitations to place them within queues instead of tasks.
    DESC
    task migrate_invitations_to_queues: :environment do
      Task.where(type: 'TahiStandardTasks::PaperReviewerTask').find_each do |task|
        task.decisions.each do |decision|
          queue = decision.create_invite_queue!
          put_invitations_into_queue(decision.invitations, queue)
        end
      end
      Task.where(type: 'TahiStandardTasks::PaperEditorTask').find_each do |task|
        queue = task.create_invite_queue!
        put_invitations_into_queue(task.invitations, queue)
      end
    end
  end

  def put_invitations_into_queue(invitations, queue)
    # get grouped invitations and 
  end

  desc <<-DESC
      APERTA-5579: Migration removes queues to default to task-invitations association

      This is intended to be run as part of a down migration.
  DESC
  task :migrate_queues_back_to_invitations do
    InviteQueue.destroy_all
  end
end
