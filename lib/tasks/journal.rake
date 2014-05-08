namespace :journal do
  desc "Add default ManuscriptManagerTemplate to all journals"
  task :create_default_templates => :environment do
    Journal.all.each do |journal|
      if journal.manuscript_manager_templates.empty?
        mmt = DefaultManuscriptManagerTemplateFactory.build
        mmt.journal = journal
        mmt.save!
        puts "Default MMT created for journal #{journal.name}"
      else
        puts "Journal #{journal.name} has MMTs already"
      end
    end
  end
end
