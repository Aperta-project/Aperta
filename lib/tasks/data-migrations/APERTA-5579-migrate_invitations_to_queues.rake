namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-5579: Migrates invitations to place them within queues instead of tasks.
    DESC
    task migrate_invitations_to_queues: :environment do
      Task.where(type: 'TahiStandardTasks::PaperReviewerTask').find_each do |task|
        if task.invite_queues.empty? && task.invitations.present?
          general_queue = InviteQueue.create(queue_title: 'Main', task: task, main_queue: true)
          sub_queues = []
          task.decisions.each do |decision|
            decision.invitations.each do |invitation|
              if invitation.alternates.empty? && invitation.primary.blank? # belongs in main queue
                invitation.invite_queue = general_queue
                invitation.save
              elsif invitation.primary.present? # Create subqueues first
                sub_queues << InviteQueue.find_or_create_by(
                  task: task,
                  queue_title: "SubQueue for: #{invitation.primary.email}",
                  main_queue: false,
                    primary: invitation.primary
                )
              end
            end
            sub_queues.each do |queue|
              queue.invitations << queue.primary
              queue.invitations << queue.primary.alternates
              queue.save
            end
          end
        end
        task.invitations.each do |invitation|
          if invitation.alternates.empty? && invitation.primary.blank? # belongs in main queue
            invitation.invite_queue = general_queue
            invitation.save
          elsif invitation.primary.present? # Create subqueues first
            sub_queues << InviteQueue.find_or_create_by(
              task: task,
              queue_title: "SubQueue for: #{invitation.primary.email}",
              main_queue: false,
                primary: invitation.primary
            )
          end
        end
        sub_queues.each do |queue|
          queue.invitations << queue.primary
          queue.invitations << queue.primary.alternates
          queue.save
        end
      end
      Task.where(type: 'TahiStandardTasks::PaperEditorTask').find_each do |task|
        if task.invite_queues.empty? && task.invitations.present?
          general_queue = InviteQueue.create(queue_title: 'Main', task: task, main_queue: true)
          task.invitations.each do |invitation|
            invitation.invite_queue = general_queue
            invitation.save
          end
        end
      end
    end
  end

  desc <<-DESC
      APERTA-5579: Migration removes queues to default to task-invitations association

      This is intended to be run as part of a down migration.
  DESC
  task :migrate_queues_back_to_invitations do
    InviteQueue.find_each do |queue|
      if queue.task.invitations.empty?
        raise <<-ERROR.strip_heredoc
            InviteQueue with id: #{queue.id} has tasks without invitations, which may indicate bad data.
            Migration is aborting.
        ERROR
      end
    end
    InviteQueue.destroy_all
  end
end

