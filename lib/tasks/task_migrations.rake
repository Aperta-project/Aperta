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

  desc "Destroy and recreate manuscript manager templates"
  task :reset_mmts => :environment do
    ManuscriptManagerTemplate.destroy_all
    Rake::Task["journal:create_default_templates"].invoke
  end
end
