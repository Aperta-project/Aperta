namespace :data do

  desc "Migrate tasks to namespacing"
  task :migrate_namespacing => :environment do
    Task.where(type: "FigureTask").update_all(type: "StandardTasks::FigureTask")
    Task.where(type: "TechCheckTask").update_all(type: "StandardTasks::TechCheckTask")
    Task.where(type: "AuthorsTask").update_all(type: "StandardTasks::AuthorsTask")
    Task.where(type: "UploadManuscriptTask").update_all(type: "UploadManuscript::Task")
    Task.where(type: "DeclarationTask").update_all(type: "Declaration::Task")
    puts "Be sure to update the task_types inside all existing ManuscriptManagerTemplates"
  end

  desc "Create default surveys for declaration tasks"
  task :create_surveys => :environment do
    DeclarationTask.all.each do |dt|
      if dt.surveys.empty?
        dt.send(:default_surveys).each(&:save)
        print "."
      end
    end
  end

  task :shorten_supporting_information do
    Task.where(title: "Supporting Information").update_all(title: "Supporting Info")
  end

end
