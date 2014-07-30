namespace :data do

  desc "Migrate tasks to namespacing"
  task :migrate_namespacing => :environment do
    Task.where(type: "FigureTask").update_all(type: "StandardTasks::FigureTask")
    Task.where(type: "TechCheckTask").update_all(type: "StandardTasks::TechCheckTask")
    Task.where(type: "AuthorsTask").update_all(type: "StandardTasks::AuthorsTask")
    Task.where(type: "UploadManuscriptTask").update_all(type: "UploadManuscript::Task")
    Task.where(type: "DataAvailability::Task").update_all(type: "StandardTasks::DataAvailabilityTask")
    Task.where(type: "CompetingInterests::Task").update_all(type: "StandardTasks::CompetingInterestsTask")
    Task.where(type: "FinancialDisclosure::Task").update_all(type: "StandardTasks::FinancialDisclosureTask")
    Task.where(type: "PaperAdminTask").update_all(type: "StandardTasks::PaperAdminTask")
    puts "Be sure to update the task_types inside all existing ManuscriptManagerTemplates"
  end

  task :shorten_supporting_information do
    Task.where(title: "Supporting Information").update_all(title: "Supporting Info")
  end

end
