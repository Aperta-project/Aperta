
#TODO: make assign_journal_role more performant

require_relative '../../spec/support/helper_methods.rb'
require 'heroku_exporter'

namespace :data do
  namespace :load do

    include TahiHelperMethods

    task :setup => :environment do
      ["db:drop", "db:create", "db:schema:load"].each do |task|
        raise "This can only be run in the performance environment" unless Rails.env.performance?
        Rake::Task[task].invoke
      end
    end

    desc "Bulk load all data"
    task :all => :setup do
      ["journals", "users", "journal_admin_users", "reviewer_users", "reviewer_and_editor_users", "completed_manuscripts"].each do |task|
        Rake::Task["data:load:" + task].invoke
      end
    end

    desc "Bulk create journals"
    task :journals => :setup do
      progress("journals", 7) do
        FactoryGirl.create(:journal)
      end
    end

    desc "Bulk create users"
    task :users => :setup do
      progress("users", 50) do
        FactoryGirl.create(:user)
      end
    end

    desc "Bulk create admin users"
    task :journal_admin_users => [:setup, :journals] do
      progress("journal admins", 10) do
        Journal.all.each do |journal|
          user = FactoryGirl.create(:user)
          assign_journal_role(journal, user, :admin)
        end
      end
    end

    desc "Bulk create reviewer users"
    task :reviewer_users => [:setup, :journals] do
      journals = Journal.all
      progress("journal reviewers", 100) do
        journals.each do |journal|
          user = FactoryGirl.create(:user)
          assign_journal_role(journals.sample, user, :reviewer)
        end
      end
    end

    desc "Bulk create users with editor and reviewer roles"
    task :reviewer_and_editor_users => :environment do
      journals = Journal.all
      progress("journal reviewers & editors", 40000) do
        journals.each do |journal|
          user = FactoryGirl.create(:user)
          assign_journal_role(journals.sample, user, :editor)
          assign_journal_role(journals.sample, user, :reviewer)
        end
      end
    end

    desc "Bulk create completed manuscripts"
    task :completed_manuscripts => [:setup, :journals, :users] do
      journals           = Array.new(Journal.all)
      first_journal      = journals.delete(journals.first)
      remaining_journals = journals

      progress("large completed manuscript", 20000) do
        FactoryGirl.create(:paper, :with_tasks, :completed, user: random(User), journal: first_journal)
      end

      progress("typical completed manuscript", 80000) do
        FactoryGirl.create(:paper, :with_tasks, :completed, user: random(User), journal: remaining_journals.sample)
      end
    end

    desc "Bulk create active manuscripts"
    task :active_manuscripts => [:setup, :journals, :users] do
      journals = Array.new(Journal.all)
      first_journal = journals.delete(journals.first)

      progress("one journal with 10k active manuscripts", 10000) do
        FactoryGirl.create(:paper, :with_tasks, user: random(User), journal: first_journal)
      end

      progress("rest of the journals with active manuscripts", 26000) do
        FactoryGirl.create(:paper, :with_tasks, user: random(User), journal: journals.sample)
      end
    end

    desc "Bulk create ad hoc tasks"
    task :ad_hoc_tasks => [:setup, :journals, :active_manuscripts] do
      progress("ad hoc tasks", 5000) do
        FactoryGirl.create(:task, phase: random(Phase))
      end
    end

    desc "Bulk create message tasks"
    task :message_tasks => [:setup, :journals, :users, :active_manuscripts] do
      progress("conversations", 50000) do
        message_task = FactoryGirl.create(:message_task, phase: random(Phase), participants: [random(User)])
        FactoryGirl.create(:comment, task: message_task, commenter: random(User))
      end


    end


    private

    def progress(display, count)
      #todo: print "display"
      ProgressBar.new(display, count) do |progress|
        count.times do
          yield
          progress.inc
        end
      end
    end

    def random(klass)
      klass.order("RANDOM()").first
    end

  end

  namespace :heroku do

    task :setup => :environment do
      database_name = ActiveRecord::Base.connection_config[:database]
      dest_filename = "#{database_name}_load_dump.sql"
      dest_file_path = Rails.root.join('tmp', dest_filename)

      @heroku_exporter = HerokuExporter.new(database_name, dest_file_path)
    end

    desc "Dump postgres data"
    task :snapshot_local do
      @heroku_exporter.snapshot!
    end

    desc "Save file to S3"
    task :copy_snapshot_to_s3 => [:environment, :setup] do
      access_key_id = ENV['AWS_ACCESS_KEY_ID']
      secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

      puts "Copying to S3...."

      @heroku_exporter.copy_to_s3(access_key_id, secret_access_key)
    end

    desc "Export snapshot to Heroku"
    task :export => [:setup] do
      @heroku_exporter.export_to_heroku!
    end

    desc "Snapshot, copy, and import local database to Heroku"
    task :import_snapshot => [:setup, :snapshot_local, :copy_snapshot_to_s3, :export]

  end
end
