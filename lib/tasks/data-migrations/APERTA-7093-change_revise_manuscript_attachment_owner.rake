namespace :data do
  namespace :migrate do
    namespace :revise_manuscript_attachment do
      desc 'Changes attachments owned by ReviseTasks to be owned by Decisions'
      task change_owner_to_decision: :environment do
        revise_tasks = Task.where(type: TahiStandardTasks::ReviseTask)
        revise_tasks.update_all(title: 'Response to Reviewers')

        count = 0
        Task.where(type: TahiStandardTasks::ReviseTask).each do |task|
          count += task.attachments.length
          decision = task.paper.decisions.order(major_version: :desc, minor_version: :desc).limit(1).first
          task.attachments.update_all(owner_type: 'Decision', owner_id: decision.id, type: 'DecisionAttachment')
        end

        count_after = DecisionAttachment.all.length
        if count_after == count
          puts "Updated #{count} attachments to be owned by decisions"
        else
          STDERR.puts "Changed #{count} attachments, but found #{count_after} DecisionAttachments"
        end
      end

      desc 'Changes attachments owned by Decisions to be owned by ReviseTasks'
      task change_owner_to_task: :environment do
        revise_tasks = Task.where(type: TahiStandardTasks::ReviseTask)
        revise_tasks.update_all(title: 'Revise Manuscript')

        count = DecisionAttachment.all.length
        DecisionAttachment.all.each do |attachment|
          attachment.type = 'AdhocAttachment'
          attachment.owner = attachment.paper.revise_task
          attachment.save
        end

        count_after = 0
        Task.where(type: TahiStandardTasks::ReviseTask).each do |task|
          count_after += task.attachments.length
        end

        if count_after == count
          puts "Updated #{count} attachments to be owned by ReviseTasks"
        else
          STDERR.puts "Changed #{count} attachments, but found #{count_after} attachments owned by ReviseTasks"
        end
      end
    end
  end
end
