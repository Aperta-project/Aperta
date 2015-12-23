require 'rails_helper'

describe "Authorizations: simple scenarios" do
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

  describe "associations" do
    let!(:user) { FactoryGirl.create(:user, first_name: 'Bob Theuser') }
    let!(:journal) { FactoryGirl.create(:journal) }
    let!(:unassigned_journal) { FactoryGirl.create(:journal) }
    let!(:paper_assigned_to_journal) { FactoryGirl.create(:paper, journal: journal) }
    let!(:other_paper_on_same_journal) { FactoryGirl.create(:paper, journal: journal) }
    let!(:paper_not_assigned_to_journal) { FactoryGirl.create(:paper) }
    let!(:some_task) { FactoryGirl.create(:task, paper: paper_assigned_to_journal) }
    let!(:task_assigned_to_other_paper) { FactoryGirl.create(:task, title: "Not assigned", paper: other_paper_on_same_journal) }

    permissions do
      permission action: 'view', applies_to: 'Journal'
      permission action: 'view', applies_to: 'Paper'
      permission action: 'view', applies_to: 'Task'
      permission action: 'view_billing_info', applies_to: 'Task'
      permission action: 'view', applies_to: 'DiscussionTopic'
    end

    role :editor do
      has_permission action: 'view', applies_to: 'Journal'
      has_permission action: 'view', applies_to: 'Paper'
      has_permission action: 'view', applies_to: 'Task'
      has_permission action: 'view', applies_to: 'DiscussionTopic'
    end

    role :task_assignee do
      has_permission action: 'view', applies_to: 'Paper'
      has_permission action: 'view', applies_to: 'Task'
    end

    before do
      journal.roles << role_editor << role_task_assignee
    end

    it "allows access to the associations of an object you have access to" do
      assign_user user, to: journal, with_role: role_editor
      expect(user.enumerate_targets(:view, Journal).objects).to eq([journal])
    end

    it "allows access to the associations of an object you have access to" do
      assign_user user, to: some_task, with_role: role_task_assignee
      expect(user.enumerate_targets(:view, Paper).objects).to eq([some_task.paper])
    end

    context "when user is assigned to a broader object than they're trying to access" do
      before do
        assign_user user, to: journal, with_role: role_task_assignee
      end

      it "returns only objects you're asking about (even though you have access to more)" do
        expect(user.enumerate_targets(:view, paper_assigned_to_journal.tasks).objects).to eq(paper_assigned_to_journal.tasks)
      end
    end

    context "when you have access to some tasks but not others (e.g billing staff)" do
      role :billing_staff do
        has_permission action: 'view', applies_to: 'Task'
        has_permission action: 'view_billing_info', applies_to: 'Task'
      end

      let!(:billing_task) { FactoryGirl.create(:billing_task, paper: paper_assigned_to_journal) }

      before do
        billing_task.update required_permission: Permission.find_by_action_and_applies_to!('view_billing_info', 'Task')
      end

      context "and you're not billing staff" do
        before do
          assign_user user, to: journal, with_role: role_task_assignee
        end

        it "doesn't include the billing tasks which require a different permission" do
          expect(user.enumerate_targets(:view, paper_assigned_to_journal.tasks).objects).to_not include(billing_task)
          expect(user.enumerate_targets(:view_billing_info, paper_assigned_to_journal.tasks).objects).to_not include(billing_task)
        end

        it "doesn't allow them to access a specific billing task they don't have permission to view" do
          expect(user.can?(:view, billing_task)).to eq(false)
          expect(user.can?(:view_billing_info, billing_task)).to eq(false)
        end
      end

      context "and you're billing staff" do
        before do
          assign_user user, to: journal, with_role: role_billing_staff
        end

        it "does include the billing tasks which require a different permission" do
          expect(user.enumerate_targets(:view_billing_info, paper_assigned_to_journal.tasks).objects).to contain_exactly(some_task, billing_task)
        end

        it "allows them to access a specific billing task they have permission to view" do
          expect(user.can?(:view_billing_info, billing_task)).to eq(true)
        end
      end
    end
  end
end
