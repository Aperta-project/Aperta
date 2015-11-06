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
      ENV['FILE'] = 'db/seeds/base.rb'
      ENV['MODELS'] = 'JournalTaskType, Journal, VersionedText, Paper, PaperRole, Task, Author, Participation,
                    Role, Affiliation, Decision,
                    ManuscriptManagerTemplate, NestedQuestion, Phase, PhaseTemplate,
                    TaskTemplate, UserRole'
      Rake::Task['db:seed:dump'].invoke
    end
  end
end

namespace :db do
  namespace :seed do
    task seed: ['environment', 'db:drop', 'db:create', 'db:schema:load'] do

    Rake::Task['data:create_task_types'].invoke
    # Create Journal
    plos_journal = Journal.first_or_create!(name: 'PLOS Yeti', logo: '', doi_publisher_prefix: "yetipub", doi_journal_prefix: "yetijour", last_doi_issued: "1000000")

    admin = User.where(email: 'admin@example.com').first_or_create! do |user|
      user.first_name = 'Admin'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'admin'
      user.site_admin = true
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
    end

    User.where(email: 'editor@example.com').first_or_create! do |user|
      user.first_name = 'Editor'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'editor'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
    end

    User.where(email: 'reviewer@example.com').first_or_create! do |user|
      user.first_name = 'Reviewer'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'reviewer'
      user.affiliations.first_or_initialize(name: "PLOS")
    end

    User.where(email: 'flow_manager@example.com').first_or_create! do |user|
      user.first_name = 'FlowManager'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'flow_manager'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::FLOW_MANAGER, name: Role::FLOW_MANAGER.titleize).first_or_initialize)
    end

    User.where(email: 'author@example.com').first_or_create! do |user|
      user.first_name = 'Author'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'author'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.roles.new(journal_id: plos_journal.id, name: "Author")
    end

    # QA Users
    # rubocop:disable Lint/UselessAssignment
    qa_admin = User.where(email: 'sealresq+7@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey SA'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_sa'
      user.site_admin = true
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
    end

    qa_ordinary_admin = User.where(email: 'sealresq+6@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey OA'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_oa'
      user.site_admin = false
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
    end

    qa_flow_manager = User.where(email: 'sealresq+5@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey FM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_flowmgr'
      user.site_admin = false
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::FLOW_MANAGER, name: Role::FLOW_MANAGER.titleize).first_or_initialize)
    end

    qa_editor = User.where(email: 'sealresq+4@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey AMM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_editor'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
    end

    qa_editor2 = User.where(email: 'sealresq+3@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey MM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_assoceditor'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
    end

    qa_reviewer = User.where(email: 'sealresq+2@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey RV'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_reviewer'
      user.affiliations.first_or_initialize(name: "PLOS")
    end

    qa_author = User.where(email: 'sealresq+1@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey AU'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_author'
      user.affiliations.first_or_initialize(name: "PLOS")
      user.roles << Role.where(name: "Author").first
    end

      ActiveRecord::Base.transaction do
        Rake::Task['db:seed:base'].invoke
      end
    end
  end
end

# rake db:seed:dump MODELS='JournalTaskType, Journal, VersionedText, Paper, PaperRole, Task, Author, Participation,
#                           Role, Affiliation, Decision,
#                           ManuscriptManagerTemplate, NestedQuestion, Phase, PhaseTemplate,
#                           TaskTemplate, UserRole' FILE='db/seeds/base.rb'
