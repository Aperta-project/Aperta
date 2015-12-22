require 'rails_helper'

describe "Authorizations: client side" do
  include AuthorizationSpecHelper

  before do
    Authorizations.configure do |config|
      config.assignment_to(Task, authorizes: Paper, via: :paper)
      config.assignment_to(Task, authorizes: Journal, via: :journal)
      config.assignment_to(Paper, authorizes: DiscussionTopic, via: :discussion_topics)
      config.assignment_to(Paper, authorizes: Task, via: :tasks)
      config.assignment_to(Paper, authorizes: Journal, via: :journal)
      config.assignment_to(Journal, authorizes: Task, via: :tasks)
      config.assignment_to(Journal, authorizes: Paper, via: :papers)
    end
  end

  after do
    Authorizations.reset_configuration
  end

  let!(:user) { FactoryGirl.create(:user, first_name: 'Bob Theuser') }
  let!(:journal) { FactoryGirl.create(:journal) }
  let!(:unassigned_journal) { FactoryGirl.create(:journal) }
  let!(:paper_assigned_to_journal) { FactoryGirl.create(:paper, journal: journal) }
  let!(:other_paper_on_same_journal) { FactoryGirl.create(:paper, journal: journal) }
  let!(:paper_not_assigned_to_journal) { FactoryGirl.create(:paper) }
  let!(:some_task) { FactoryGirl.create(:task, paper: paper_assigned_to_journal) }

  permissions do
    permission action: 'read', applies_to: 'Paper'
    permission action: 'write', applies_to: 'Paper', states: ['in_progress']
    permission action: 'view', applies_to: 'Paper'
    permission action: 'talk', applies_to: 'Paper', states: ['in_progress', 'in_review']
  end

  role :editor do
    has_permission action: 'read', applies_to: 'Paper'
    has_permission action: 'write', applies_to: 'Paper'
    has_permission action: 'view', applies_to: 'Paper'
    has_permission action: 'talk', applies_to: 'Paper'
  end

  role :task_assignee do
    has_permission action: 'write', applies_to: 'Paper'
    has_permission action: 'view', applies_to: 'Paper'
  end

  before do
    journal.roles << role_editor << role_task_assignee
    assign_user user, to: paper_assigned_to_journal, with_role: role_editor
    assign_user user, to: other_paper_on_same_journal, with_role: role_editor
  end

  describe "presenting information to the client" do
    it "can be presented as a lookup table" do
      results = user.enumerate_targets(:view, Paper)
      expect(results.to_h).to eq([
       {
         object: {
           id: paper_assigned_to_journal.id,
           type: "Paper"
         },
         permissions: {
          read: { states: ["*"] },
          write: { states: ["in_progress"] },
          view: { states: ["*"] },
          talk: { states: ["in_progress", "in_review"] }
        }
       },
       {
         object: {
           id: other_paper_on_same_journal.id,
           type: "Paper"
         },
         permissions: {
          read: { states: ["*"] },
          write: { states: ["in_progress"] },
          view: { states: ["*"] },
          talk: { states: ["in_progress", "in_review"] }
        }
       }
      ])
    end
  end
end
