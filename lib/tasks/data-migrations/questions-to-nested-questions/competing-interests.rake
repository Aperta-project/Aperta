namespace 'data:migrate:questions-to-nested-questions' do
  namespace :'competing-interests' do
    desc "Resets the NestedQuestionAnswer(s) for competing interests by destroying them."
    task :reset => :environment do
      DataMigrator::CompetingInterestsQuestionsMigrator.reset
    end

    desc "Destroy old questions for competing interests once you're satisfied w/migrating to NestedQuestion data model."
    task :cleanup => :environment do
      DataMigrator::CompetingInterestsQuestionsMigrator.cleanup
    end
  end

  desc "Migrate the competing interests task data to the NestedQuestion data model."
  task :'competing-interests' => 'data:migrate:questions-to-nested-questions:competing-interests:reset' do
    DataMigrator::CompetingInterestsQuestionsMigrator.migrate!
  end
end
