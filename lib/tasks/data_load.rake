# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

namespace :data do
  namespace :load do
    task setup: :environment do
      ["db:drop", "db:create", "db:schema:load"].each do |task|
        raise "This can only be run in the performance environment" unless Rails.env.performance?
        Rake::Task[task].invoke
      end
    end

    desc "Bulk load all data"
    task all: :setup do
      ["journals", "users", "journal_admin_users", "reviewer_users", "reviewer_and_editor_users", "completed_manuscripts", "active_manuscripts"].each do |task|
        Rake::Task["data:load:" + task].invoke
      end
    end

    desc "Bulk create journals"
    task journals: :setup do
      desired_journals = 7

      progress("journals", desired_journals) do
        FactoryGirl.create(:journal)
      end
    end

    desc "Bulk create users"
    task users: :setup do
      desired_users = 50

      progress("users", desired_users) do
        FactoryGirl.create(:user)
      end
    end

    desc "Bulk create admin users"
    task journal_admin_users: [:setup, :journals] do
      desired_users = 200

      progress("journal admins", desired_users) do
        user = FactoryGirl.create(:user)
        assign_journal_role(Journal.all.sample, user, :admin)
      end
    end

    desc "Bulk create reviewer users"
    task reviewer_users: [:setup, :journals] do
      desired_users = 100_000

      progress("journal reviewers", desired_users) do
        user = FactoryGirl.create(:user)
        assign_journal_role(Journal.all.sample, user, :reviewer)
      end
    end

    desc "Bulk create users with editor and reviewer roles"
    task reviewer_and_editor_users: :environment do
      desired_users = 50_000

      progress("journal reviewers & editors", desired_users) do
        user = FactoryGirl.create(:user)
        journal = Journal.all.sample
        assign_journal_role(journal, user, :editor)
        assign_journal_role(journal, user, :reviewer)
      end
    end

    desc "Bulk create completed manuscripts"
    task completed_manuscripts: [:setup, :journals, :users] do
      journals           = Array.new(Journal.all)
      first_journal      = journals.delete(journals.first)
      remaining_journals = journals

      desired_papers = 20_000
      progress("large completed manuscript", desired_papers) do
        FactoryGirl.create(:paper, :with_tasks, :completed, creator: random(User), journal: first_journal)
      end

      desired_papers = 80_000
      progress("typical completed manuscript", desired_papers) do
        FactoryGirl.create(:paper, :with_tasks, :completed, creator: random(User), journal: remaining_journals.sample)
      end
    end

    desc "Bulk create active manuscripts"
    task active_manuscripts: [:setup, :journals, :users] do
      journals = Array.new(Journal.all)
      first_journal = journals.delete(journals.first)

      desired_papers = 10_000
      progress("one journal with 10k active manuscripts", desired_papers) do
        FactoryGirl.create(:paper, :with_tasks, user: random(User), journal: first_journal)
      end

      desired_papers = 26_000
      progress("rest of the journals with active manuscripts", desired_papers) do
        FactoryGirl.create(:paper, :with_tasks, creator: random(User), journal: journals.sample)
      end
    end

    desc "Bulk create ad hoc tasks"
    task ad_hoc_tasks: [:setup, :journals, :active_manuscripts] do
      desired_tasks = 5_000
      progress("ad hoc tasks", desired_tasks) do
        FactoryGirl.create(:ad_hoc_task, phase: random(Phase))
      end
    end

    desc "Bulk create conversations"
    task conversations: [:setup, :journals, :users, :active_manuscripts, :ad_hoc_tasks] do
      desired_comments_per = 10
      AdHocTask.find_each do |task|
        FactoryGirl.create(:participation, user: random(User), task: task)
        progress("conversations", desired_comments_per) do
          FactoryGirl.create(:comment, task: task, commenter: random(User))
        end
      end
    end

    private

    def progress(display, count)
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

  task validate: :environment do
    tables = ActiveRecord::Base.connection.tables

    tables.each do |table|
      begin
        i = 0
        model = table.singularize.camelize.constantize
        model.find_each do |record|
          unless record.valid?
            i += 1
            puts record.inspect
          end
        end

        p "====> #{i} Issues in #{model}"
      rescue
        p "error on #{table}... this table probably does not correspond to a Rails model"
      end
    end
  end
end

def assign_journal_role(journal, user, type)
  role = journal.roles.where(kind: type).first
  role ||= FactoryGirl.create(:role, type, journal: journal)
  UserRole.create!(user: user, role: role)
  role
end
