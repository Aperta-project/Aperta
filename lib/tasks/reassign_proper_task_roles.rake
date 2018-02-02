namespace :tahi do
  desc "Restores default role for editor and reviewer tasks"
  task restore_original_task_roles: :environment do
    i = 0
    editor_tasks = ["PaperReviewerTask", "RegisterDecisionTask"]

    JournalTaskType.where('kind = ? OR kind = ?', *editor_tasks).each do |jtt|
      jtt.update! role: 'editor'
      i += 1
    end

    JournalTaskType.where(kind: "ReviewerReportTask").each do |jtt|
      jtt.update! role: 'reviewer'
      i += 1
    end

    Task.where('type = ? OR type = ?', *editor_tasks).each do |task|
      task.update_column 'role', 'editor'
      i += 1
    end

    Task.where(type: "ReviewerReportTask").each do |task|
      task.update_column 'role', 'reviewer'
      i += 1
    end

    puts "#{i} Tasks updated"
  end
end
