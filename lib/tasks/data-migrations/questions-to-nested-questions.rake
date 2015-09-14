namespace 'data:migrate:questions-to-nested-questions' do
  DATA_MIGRATION_QUESTION_RAKE_TASKS = %w( competing-interests data-availability )

  desc "Calls :reset task for all question-to-nested-question(s)"
  task :reset_all => :environment do
    tasks_as_strings = DATA_MIGRATION_QUESTION_RAKE_TASKS.map do |t|
      ["data:migrate:questions-to-nested-questions:#{t}:reset"]
    end.flatten.each do |task_as_string|
      Rake::Task[task_as_string].invoke
    end
  end

  desc "Runs the migrations for all question-to-nested-question(s)"
  task :migrate_all => :environment do
    tasks_as_strings = DATA_MIGRATION_QUESTION_RAKE_TASKS.map do |t|
      ["data:migrate:questions-to-nested-questions:#{t}"]
    end.flatten.each do |task_as_string|
      Rake::Task[task_as_string].invoke
    end
  end

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
  task :'competing-interests' => 'data:migrate:questions-to-nested-questions:data-availability:reset' do
    DataMigrator::CompetingInterestsQuestionsMigrator.migrate!
  end

  namespace :'data-availability' do
    desc "Resets the NestedQuestionAnswer(s) for data availability by destroying them."
    task :reset => :environment do
      DataMigrator::DataAvailabilityQuestionsMigrator.reset
    end

    desc "Destroy old questions for data availability once you're satisfied w/migrating to NestedQuestion data model."
    task :cleanup => :environment do
      DataMigrator::DataAvailabilityQuestionsMigrator.cleanup
    end
  end

  desc "Migrate the data availability task data to the NestedQuestion data model."
  task :'data-availability' => 'data:migrate:questions-to-nested-questions:data-availability:reset' do
    DataMigrator::DataAvailabilityQuestionsMigrator.migrate!
  end
end
