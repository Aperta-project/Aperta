# lib/tasks/custom_seed.rake
namespace :db do
  namespace :seed do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').to_sym
      task task_name => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end
end

namespace :db do
  namespace :seed do
    task dump_db: :environment do
      Rake::Task['db:seed:dump'].invoke
    end
  end
end

# rake db:seed:dump MODELS='JournalTaskType, Journal, VersionedText, Paper, PaperRole, Task, Author, Participation,
#                           Role, Affiliation, Decision,
#                           ManuscriptManagerTemplate, NestedQuestion, Phase, PhaseTemplate,
#                           TaskTemplate, UserRole' FILE='db/seeds/base.rb'
