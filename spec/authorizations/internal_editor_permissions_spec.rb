require 'rails_helper'

describe "Authorizations: internal editors" do
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
  let!(:paper_not_assigned_to_journal) { FactoryGirl.create(:paper) }
  let!(:task_in_paper) { FactoryGirl.create(:task, paper: paper_assigned_to_journal) }

  permissions do
    permission action: 'can_send_decision_letter', applies_to: 'Paper'
    permission action: 'can_view_papers', applies_to: 'Paper'
    permission action: 'can_write_decision_letter', applies_to: 'Paper'
    permission action: 'can_add_participant', applies_to: 'Paper'
    permission action: 'can_add_task_participant', applies_to: 'Task'
    permission action: 'edit', applies_to: 'Paper', states: ['submitted']
  end

  role :editor do
    has_permission action: 'can_view_papers', applies_to: 'Paper'
    has_permission action: 'can_send_decision_letter', applies_to: 'Paper'
    has_permission action: 'can_write_decision_letter', applies_to: 'Paper'
    has_permission action: 'can_add_participant', applies_to: 'Paper'
    has_permission action: 'can_add_task_participant', applies_to: 'Task'
    has_permission action: 'edit', applies_to: 'Paper'
  end

  before do
    journal.roles << role_editor
    assign_user user, to: journal, with_role: role_editor
  end

  describe 'can view papers in the journal' do
    it 'allows the user to view papers on the journal they are assigned to' do
      expect(user.can?(:can_view_papers, paper_assigned_to_journal)).to be true

      10.times { FactoryGirl.create(:paper, journal: journal) }
      expect(user.enumerate_targets(:can_view_papers, Paper).objects).to eq(journal.papers)
    end

    it 'does not allow the user to have a permission not explicitly granted for this journal' do
      expect(user.can?(:can_edit_papers, paper_assigned_to_journal)).to be false

      unviewable_papers = 10.times.map { FactoryGirl.create(:paper) }
      expect(user.enumerate_targets(:can_view_papers, Paper).objects).to_not include(*unviewable_papers)
    end
  end

  describe 'can send decision letters in the journal' do
    it 'allows the user to view papers on the journal they are assigned to' do
      expect(user.can?(:can_send_decision_letter, paper_assigned_to_journal)).to be true
    end
  end

  describe 'can write decision letters' do
    it 'allows the user to write a decision letter on a paper in the journal they are assigned to' do
      expect(user.can?(:can_write_decision_letter, paper_assigned_to_journal)).to be true
    end

    it 'does not allow the user to write a decision letter on a paper in the journal they are not assigned to' do
      expect(user.can?(:can_write_decision_letter, paper_not_assigned_to_journal)).to be false
    end
  end

  describe 'can add participatants to any card or paper' do
    it 'allows the user to add a participant to a paper' do
      expect(user.can?(:can_add_participant, paper_assigned_to_journal)).to be true
    end

    it 'allows the user to add a participant to a task' do
      expect(user.can?(:can_add_task_participant, task_in_paper)).to be true
    end
  end

  describe '#enumerate_targets' do
    let!(:paper1) { FactoryGirl.create(:paper, publishing_state: 'submitted', journal: journal) }
    let!(:paper2) { FactoryGirl.create(:paper, publishing_state: 'submitted', journal: journal) }

    it 'works' do
      expect(user.enumerate_targets(:edit, Paper).objects).to include(paper1, paper2)
    end
  end

  context 'when the paper is submitted' do
    let(:paper) { FactoryGirl.create(:paper, publishing_state: 'submitted', journal: journal) }

    describe 'the editor' do
      it 'can edit the paper' do
        expect(user.can?(:edit, paper)).to be true
      end
    end
  end

  context 'when the paper is published' do
    let(:paper) { FactoryGirl.create(:paper, publishing_state: 'published', journal: journal) }

    describe 'the editor' do
      it 'cannot edit the paper' do
        expect(user.can?(:edit, paper)).to be false
      end
    end
  end
end
