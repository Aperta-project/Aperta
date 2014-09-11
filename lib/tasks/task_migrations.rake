namespace :data do

  desc "Create default task types for all journals"
  task :create_task_types => :environment do
    TaskServices::CreateTaskTypes.call
    Journal.all.each do |journal|
      JournalServices::CreateDefaultTaskTypes.call(journal)
    end
  end

  task :shorten_supporting_information do
    Task.where(title: "Supporting Information").update_all(title: "Supporting Info")
  end
end
