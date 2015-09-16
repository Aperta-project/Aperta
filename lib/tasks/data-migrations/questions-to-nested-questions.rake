namespace 'data:migrate:questions-to-nested-questions' do
  DATA_MIGRATION_QUESTION_RAKE_TASKS = %w(
    competing-interests data-availability ethics figures financial-disclosure
  )

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

  namespace :'ethics' do
    desc "Resets the NestedQuestionAnswer(s) for ethics by destroying them."
    task :reset => :environment do
      DataMigrator::EthicsQuestionsMigrator.reset
    end

    desc "Destroy old questions for ethics once you're satisfied w/migrating to NestedQuestion data model."
    task :cleanup => :environment do
      DataMigrator::EthicsQuestionsMigrator.cleanup
    end
  end

  desc "Migrate the ethics task data to the NestedQuestion data model."
  task :'ethics' => 'data:migrate:questions-to-nested-questions:ethics:reset' do
    DataMigrator::EthicsQuestionsMigrator.migrate!
  end

  namespace :'figures' do
    desc "Resets the NestedQuestionAnswer(s) for figures by destroying them."
    task :reset => :environment do
      DataMigrator::FigureQuestionsMigrator.reset
    end

    desc "Destroy old questions for figures once you're satisfied w/migrating to NestedQuestion data model."
    task :cleanup => :environment do
      DataMigrator::FigureQuestionsMigrator.cleanup
    end
  end

  desc "Migrate the figures task data to the NestedQuestion data model."
  task :'figures' => 'data:migrate:questions-to-nested-questions:figures:reset' do
    DataMigrator::FigureQuestionsMigrator.migrate!
  end

  namespace :'financial-disclosure' do
    desc "Resets the NestedQuestionAnswer(s) for financial-disclosure by destroying them."
    task :reset => :environment do
      DataMigrator::FinancialDisclosureQuestionsMigrator.reset
    end

    desc "Destroy old questions for financial-disclosure once you're satisfied w/migrating to NestedQuestion data model."
    task :cleanup => :environment do
      DataMigrator::FinancialDisclosureQuestionsMigrator.cleanup
    end
  end

  desc "Migrate the financial-disclosure task data to the NestedQuestion data model."
  task :'financial-disclosure' => 'data:migrate:questions-to-nested-questions:figures:reset' do
    DataMigrator::FinancialDisclosureQuestionsMigrator.migrate!
  end

end
