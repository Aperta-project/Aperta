namespace :paper_tracker_seed_data do
  task setup: :environment do
    ["db:drop", "db:setup"].each do |task|
      raise "This can only be run in the development environment" unless Rails.env.development?
      Rake::Task[task].invoke
    end
  end

  desc "Create paper tracker testing seed data"
  task :create, [:num] => [:setup, :environment] do|t, args|
    raise "You must pass an array containing an integer" unless args[:num]
    count = args[:num].to_i
    count.times do |count|
      begin
        paper = FactoryGirl.create(:paper)
        paper.update_column(:publishing_state, "submitted")
        puts "created paper # #{count}"
      rescue Redis::CannotConnectError
        puts "============================"
        puts "============================"
        puts "IGNORED REDIS ERROR"
        puts "============================"
        puts "============================"
      end
    end

  end

  # desc "Bulk load all data"
  # task all: :setup do
  #   ["journals", "users", "journal_admin_users", "reviewer_users", "reviewer_and_editor_users", "completed_manuscripts", "active_manuscripts"].each do |task|
  #     Rake::Task["data:load:" + task].invoke
  #   end
  # end

  # desc "Bulk create journals"
  # task journals: :setup do
  #   desired_journals = 7

  #   progress("journals", desired_journals) do
  #     FactoryGirl.create(:journal)
  #   end
  # end

  # desc "Bulk create users"
  # task users: :setup do
  #   desired_users = 50

  #   progress("users", desired_users) do
  #     FactoryGirl.create(:user)
  #   end
  # end

  # desc "Bulk create admin users"
  # task journal_admin_users: [:setup, :journals] do
  #   desired_users = 200

  #   progress("journal admins", desired_users) do
  #     user = FactoryGirl.create(:user)
  #     assign_journal_role(Journal.all.sample, user, :admin)
  #   end
  # end

  # desc "Bulk create reviewer users"
  # task reviewer_users: [:setup, :journals] do
  #   desired_users = 100_000

  #   progress("journal reviewers", desired_users) do
  #     user = FactoryGirl.create(:user)
  #     assign_journal_role(Journal.all.sample, user, :reviewer)
  #   end
  # end

  # desc "Bulk create users with editor and reviewer roles"
  # task reviewer_and_editor_users: :environment do
  #   desired_users = 50_000

  #   progress("journal reviewers & editors", desired_users) do
  #     user = FactoryGirl.create(:user)
  #     journal = Journal.all.sample
  #     assign_journal_role(journal, user, :editor)
  #     assign_journal_role(journal, user, :reviewer)
  #   end
  # end

  # desc "Bulk create completed manuscripts"
  # task completed_manuscripts: [:setup, :journals, :users] do
  #   journals           = Array.new(Journal.all)
  #   first_journal      = journals.delete(journals.first)
  #   remaining_journals = journals

  #   desired_papers = 20_000
  #   progress("large completed manuscript", desired_papers) do
  #     FactoryGirl.create(:paper, :with_tasks, :completed, creator: random(User), journal: first_journal)
  #   end

  #   desired_papers = 80_000
  #   progress("typical completed manuscript", desired_papers) do
  #     FactoryGirl.create(:paper, :with_tasks, :completed, creator: random(User), journal: remaining_journals.sample)
  #   end
  # end

  # desc "Bulk create active manuscripts"
  # task active_manuscripts: [:setup, :journals, :users] do
  #   journals = Array.new(Journal.all)
  #   first_journal = journals.delete(journals.first)

  #   desired_papers = 10_000
  #   progress("one journal with 10k active manuscripts", desired_papers) do
  #     FactoryGirl.create(:paper, :with_tasks, user: random(User), journal: first_journal)
  #   end

  #   desired_papers = 26_000
  #   progress("rest of the journals with active manuscripts", desired_papers) do
  #     FactoryGirl.create(:paper, :with_tasks, creator: random(User), journal: journals.sample)
  #   end
  # end

  # desc "Bulk create ad hoc tasks"
  # task ad_hoc_tasks: [:setup, :journals, :active_manuscripts] do
  #   desired_tasks = 5_000
  #   progress("ad hoc tasks", desired_tasks) do
  #     FactoryGirl.create(:ad_hoc_task, phase: random(Phase))
  #   end
  # end

  # desc "Bulk create conversations"
  # task conversations: [:setup, :journals, :users, :active_manuscripts, :ad_hoc_tasks] do
  #   desired_comments_per = 10
  #   AdHocTask.find_each do |task|
  #     FactoryGirl.create(:participation, user: random(User), task: task)
  #     progress("conversations", desired_comments_per) do
  #       FactoryGirl.create(:comment, task: task, commenter: random(User))
  #     end
  #   end
  # end

  # private

  # def progress(display, count)
  #   ProgressBar.new(display, count) do |progress|
  #     count.times do
  #       yield
  #       progress.inc
  #     end
  #   end
  # end

  # def random(klass)
  #   klass.order("RANDOM()").first
  # end
end

# def assign_journal_role(journal, user, type)
#   role = journal.roles.where(kind: type).first
#   role ||= FactoryGirl.create(:role, type, journal: journal)
#   UserRole.create!(user: user, role: role)
#   role
# end
