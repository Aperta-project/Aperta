namespace :data do
  desc "Create default task types for all journals"
  task :create_task_types => :environment do
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
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

  task :copy_task_template_title => :environment do
    TaskTemplate.where(title: nil).find_each do |template|
      template.update_attribute(:title, template.journal_task_type.try(:title))
    end
  end

  task :convert_author_tasks => :environment do
    Task.where(type: "StandardTasks::AuthorsTask").update_all(type: "PlosAuthors::PlosAuthorsTask", completed: false)
  end
end
