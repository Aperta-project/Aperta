require 'rails_helper'

describe "Authorizations: reviewers" do
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
  let!(:paper_assigned_to_journal) { FactoryGirl.create(:paper, journal: journal) }
  let!(:other_paper_on_same_journal) { FactoryGirl.create(:paper, journal: journal) }
  let!(:paper_not_assigned_to_journal) { FactoryGirl.create(:paper) }
  let!(:reviewer_report_task) { FactoryGirl.create(:task, paper: paper_assigned_to_journal) }
  let!(:task_not_assigned_to_user) { FactoryGirl.create(:task, paper: paper_assigned_to_journal) }

  permissions do
    permission action: 'view', applies_to: 'Paper'
    permission action: 'view', applies_to: 'Task'
    permission action: 'view', applies_to: 'DiscussionTopic'
  end

  role :reviewer do
    has_permission action: 'view', applies_to: 'Paper'
    has_permission action: 'view', applies_to: 'Task'
    has_permission action: 'view', applies_to: 'DiscussionTopic'
  end

  before do
    journal.roles << role_reviewer
    assign_user user, to: reviewer_report_task, with_role: role_reviewer
  end

  describe 'default list of accessible papers (e.g. to populate the dashboard)' do
    it 'includes only papers through roles that indicate the papers should be accessible by default' do
      role_reviewer.update_attribute :participates_in_papers, true
      expect(user.enumerate_targets(:view, Paper.all).objects).to eq([reviewer_report_task.paper])
    end

    it 'does not include papers through roles that do not indicate papers should should be accessibled by default' do
      role_reviewer.update_attribute :participates_in_papers, false
      expect(user.enumerate_targets(:view, Paper.all).objects).to_not include(reviewer_report_task.paper)
    end
  end

  describe 'can view paper they are assigned to' do
    it 'allows the user to view a paper they are are assigned to' do
      expect(user.can?(:view, paper_assigned_to_journal)).to be true
    end

    it 'does not allow the user to view papers on the same journal that they are not assigned to' do
      expect(user.can?(:view, other_paper_on_same_journal)).to be false
    end

    it 'does not allow the user to view papers on different journals' do
      expect(user.can?(:view, paper_not_assigned_to_journal)).to be false
    end
  end

  describe 'can view only their reviewer report' do
    it 'allows the user to view the reviewer report task assigned to them' do
      expect(user.can?(:view, reviewer_report_task)).to be true
    end

    it 'does not allow the user to view the tasks not assigned to them' do
      expect(user.can?(:view, task_not_assigned_to_user)).to be false
    end

    it 'does not allow the user to view all tasks at the paper level' do
      another_task_on_the_paper = FactoryGirl.create(:task, paper: paper_assigned_to_journal)
      expect(user.can?(:view, another_task_on_the_paper)).to be false
    end

    it 'does not allow the user to view all tasks at the journal level' do
      expect(user.can?(:view, journal)).to be false
    end
  end

  describe 'can only view discussions they are assigned to' do
    let!(:discussion_assigned_on_paper){ FactoryGirl.create(:discussion_topic, paper: paper_assigned_to_journal) }
    let!(:discussion_not_assigned_on_paper){ FactoryGirl.create(:discussion_topic, paper: paper_assigned_to_journal) }
    let!(:discussion_for_another_paper){ FactoryGirl.create(:discussion_topic, paper: other_paper_on_same_journal) }

    before do
      assign_user user, to: discussion_assigned_on_paper, with_role: role_reviewer
    end

    it 'allows the user to view the discussion_topic they are assigned to' do
      expect(user.can?(:view, discussion_assigned_on_paper)).to be true
    end

    it 'does not allow the user to view the discussions they are not assigned to on the same paper' do
      expect(user.can?(:view, discussion_not_assigned_on_paper)).to be false
    end

    it 'does not allow the user to view the discussions that are assigned to other papers' do
      expect(user.can?(:view, discussion_for_another_paper)).to be false
    end
  end

  describe 'a user with access to the same object through multiple permissions' do
    before do
      assign_user user, to: journal, with_role: role_reviewer
    end

    it 'only returns the object once (no duplicates)' do
      expect(user.enumerate_targets(:view, Paper).objects).to eq(journal.papers)
    end
  end
end
