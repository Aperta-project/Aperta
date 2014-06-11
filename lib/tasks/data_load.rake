
#TODO: make assign_journal_role more performant

require_relative '../../spec/support/helper_methods.rb'
require 'heroku_exporter'

namespace :data do
  namespace :load do

    include TahiHelperMethods

    task :setup => :environment do
      ["db:drop", "db:create", "db:schema:load"].each do |task|
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
    task :reviewer_and_editor_users => [:setup, :journals] do
      journals = Journal.all
      progress("journal reviewers & editors", 50) do
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

      progress("large completed manuscript", 20) do
        FactoryGirl.create(:paper, :with_tasks, :completed, user: User.order("RANDOM()").first, journal: first_journal)
      end

      progress("typical completed manuscript", 80) do
        FactoryGirl.create(:paper, :with_tasks, :completed, user: User.order("RANDOM()").first, journal: remaining_journals.sample)
      end
    end

    desc "Bulk create active manuscripts"
    task :active_manuscripts => [:setup, :journals, :users] do
      journals = Array.new(Journal.all)
      first_journal = journals.delete(journals.first)

      progress("one journal with 10k active manuscripts", 10) do
        FactoryGirl.create(:paper, :with_tasks, user: User.order("RANDOM()").first, journal: first_journal)
      end

      progress("rest of the journals with active manuscripts", 26) do
        FactoryGirl.create(:paper, :with_tasks, user: User.order("RANDOM()").first, journal: journals.sample)
      end
    end

    desc "Bulk create ad hoc tasks"
    task :ad_hoc_tasks => [:setup, :journals, :active_manuscripts] do
      progress("ad hoc tasks", 5) do
        FactoryGirl.create(:task, phase: Phase.order("RANDOM()").first)
      end
    end

    desc "Bulk create message tasks"
    task :message_tasks => [:setup, :journals, :users, :active_manuscripts] do
      progress("conversations", 10) do
        message_task = FactoryGirl.create(:message_task, phase: random(Phase))
        FactoryGirl.create(:comment, task: message_task, commenter: random(User))
      end


    end

    #todo: postgres_dump
    namespace :heroku do

      database_name = "tahi_#{Rails.env}"
      dest_file = "tahi_#{Rails.env}_load_dump.sql"
      heroku_exporter = HerokuExporter.new(database_name, dest_file)

      desc "Dump postgres data"
      task :dump do
        heroku_exporter.dump!
      end

      desc "Save file to S3 so Heroku can access"
      task :save_dump_to_s3 => [:setup, :dump] do
        puts "Copying to S3"
        access_key_id = ENV['AWS_ACCESS_KEY_ID']
        secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        heroku_exporter.copy_to_s3(access_key_id, secret_access_key)
        heroku_exporter.export_to_heroku!
      end

      desc "Load dumped data"
      task :load_dump do

      end
    end

    #todo: load_to_heroku

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
end
