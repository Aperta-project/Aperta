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

  describe "Direct assignments" do
    let!(:user) { FactoryGirl.create(:user, first_name: "User") }
    let!(:other_user) { FactoryGirl.create(:user, first_name: "Other User") }

    let!(:paper) { FactoryGirl.create(:paper, title: "User's paper") }
    let!(:other_paper){ FactoryGirl.create(:paper, title: "Other User's paper") }

    permissions do
      permission action: 'view', applies_to: 'Paper'
    end

    role :author do
      has_permission action: 'view', applies_to: 'Paper'
    end

    before do
      assign_user user, to: paper, with_role: role_author
      assign_user other_user, to: other_paper, with_role: role_author
    end

    it "allows a user to view a paper they're directly assigned when the permission applies_to is paper" do
      expect(user.can?(:view, paper)).to be(true)
      expect(other_user.can?(:view, other_paper)).to be(true)
    end

    it "doesn't allow a user to view a paper they're assigned to when the only permission's applies_to is journal" do
      role_author.permissions.where(action: 'view', applies_to: 'Paper').update_all(applies_to: 'Journal')
      expect(user.can?(:view, paper)).to be(false)
      expect(other_user.can?(:view, other_paper)).to be(false)
    end

    it "doesn't allow a user to view a paper they're assigned to when the only permission's applies_to is task" do
      role_author.permissions.where(action: 'view', applies_to: 'Paper').update_all(applies_to: 'Task')
      expect(user.can?(:view, paper)).to be(false)
      expect(other_user.can?(:view, other_paper)).to be(false)
    end

    it "doesn't allow a user to view a paper they're not assigned to" do
      expect(user.can?(:view, other_paper)).to be(false)
      expect(other_user.can?(:view, paper)).to be(false)
    end
  end

  describe "Cascading permissions" do

    #      THE BELOW TESTS USE THIS ASSIGNMENT / PERMISSION TABLE
    #
    # ---------------------------------------------------------------------------
    # |                         | applies_to: Task | applies_to: Paper  | applies_to: Journal |
    # ---------------------------------------------------------------------------
    # | assigned_to: Task(1)    | Task(1)          | Paper(1)           | Journal(1)           |
    # | assigned_to: Task(3)    | Task(3)          | Paper(2)           | Journal(1)           |
    # | assigned_to: Paper(1)   | Task(1, 2)       | Paper(1)           | Journal(1)           |
    # | assigned_to: Journal(1) | Task(1, 2, 3, 4) | Paper(1, 2)        | Journal(1)           |
    # ---------------------------------------------------------------------------
    #

    let!(:journal) { FactoryGirl.create(:journal) }

    let!(:paper_1) { FactoryGirl.create(:paper, journal: journal) }
    let!(:task_1_in_paper_1) { FactoryGirl.create(:task, paper: paper_1) }
    let!(:task_2_in_paper_1) { FactoryGirl.create(:task, paper: paper_1) }

    let!(:paper_2) { FactoryGirl.create(:paper, journal: journal) }
    let!(:task_3_in_paper_2) { FactoryGirl.create(:task, paper: paper_2) }
    let!(:task_4_in_paper_2) { FactoryGirl.create(:task, paper: paper_2) }

    let!(:journal_admin) { FactoryGirl.create(:user, first_name: "Journal admin") }
    let!(:paper_1_author) { FactoryGirl.create(:user, first_name: "Paper Author") }
    let!(:paper_2_author) { FactoryGirl.create(:user, first_name: "Paper Author") }
    let!(:task_1_assignee) { FactoryGirl.create(:user, first_name: "Task Assignee") }
    let!(:task_3_assignee) { FactoryGirl.create(:user, first_name: "Task Assignee") }

    permissions do
      permission action: 'view', applies_to: 'Journal'
      permission action: 'view', applies_to: 'Paper'
      permission action: 'view', applies_to: 'Task'
    end

    role :journal_admin do
      has_permission action: 'view', applies_to: 'Journal'
      has_permission action: 'view', applies_to: 'Paper'
      has_permission action: 'view', applies_to: 'Task'
    end

    role :paper_author do
      has_permission action: 'view', applies_to: 'Paper'
      has_permission action: 'view', applies_to: 'Task'
    end

    role :task_assignee do
      has_permission action: 'view', applies_to: 'Task'
    end

    before do
      journal.roles.push role_journal_admin, role_paper_author, role_task_assignee
      assign_user journal_admin, to: journal, with_role: role_journal_admin
      assign_user paper_1_author, to: paper_1, with_role: role_paper_author
      assign_user paper_2_author, to: paper_2, with_role: role_paper_author
      assign_user task_1_assignee, to: task_1_in_paper_1, with_role: role_task_assignee
      assign_user task_3_assignee, to: task_3_in_paper_2, with_role: role_task_assignee
    end

    context 'cascading down based on journal permission applies_to' do
      it 'allows a journal admin to view the journal they are assigned to' do
        expect(journal_admin.can?(:view, journal)).to be true
      end

      it 'allows a journal admin to view all papers within the journal' do
        expect(journal_admin.can?(:view, paper_1)).to be true
        expect(journal_admin.can?(:view, paper_2)).to be true
      end

      it 'allows a journal admin to view all tasks within the journal' do
        expect(journal_admin.can?(:view, task_1_in_paper_1)).to be true
        expect(journal_admin.can?(:view, task_2_in_paper_1)).to be true
        expect(journal_admin.can?(:view, task_3_in_paper_2)).to be true
        expect(journal_admin.can?(:view, task_4_in_paper_2)).to be true
      end
    end

    context 'cascading down based on paper permission applies_to' do
      it 'does not allow a paper author to view the journal' do
        expect(paper_1_author.can?(:view, journal)).to be false
      end

      it 'allows a paper author to view the paper they are assigned to, but not others' do
        expect(paper_1_author.can?(:view, paper_1)).to be true
        expect(paper_1_author.can?(:view, paper_2)).to be false
      end

      it 'allows a paper author to view all tasks within the journal they are assigned to, but not others' do
        expect(paper_1_author.can?(:view, task_1_in_paper_1)).to be true
        expect(paper_1_author.can?(:view, task_2_in_paper_1)).to be true
        expect(paper_1_author.can?(:view, task_3_in_paper_2)).to be false
        expect(paper_1_author.can?(:view, task_4_in_paper_2)).to be false

        expect(paper_2_author.can?(:view, task_1_in_paper_1)).to be false
        expect(paper_2_author.can?(:view, task_2_in_paper_1)).to be false
        expect(paper_2_author.can?(:view, task_3_in_paper_2)).to be true
        expect(paper_2_author.can?(:view, task_4_in_paper_2)).to be true
      end
    end

    context 'cascading down based on task permission applies_to' do
      it 'does not allow a task assignee to view the journal' do
        expect(task_1_assignee.can?(:view, journal)).to be false
        expect(task_3_assignee.can?(:view, journal)).to be false
      end

      it 'does not allow a task assignee to view the paper of their task or other papers' do
        expect(task_1_assignee.can?(:view, paper_1)).to be false
        expect(task_1_assignee.can?(:view, paper_2)).to be false
        expect(task_3_assignee.can?(:view, paper_1)).to be false
        expect(task_3_assignee.can?(:view, paper_2)).to be false
      end

      it 'allows a paper author to view all tasks they are assigned to, but not others' do
        expect(task_1_assignee.can?(:view, task_1_in_paper_1)).to be true
        expect(task_1_assignee.can?(:view, task_2_in_paper_1)).to be false
        expect(task_1_assignee.can?(:view, task_3_in_paper_2)).to be false
        expect(task_1_assignee.can?(:view, task_4_in_paper_2)).to be false

        expect(task_3_assignee.can?(:view, task_1_in_paper_1)).to be false
        expect(task_3_assignee.can?(:view, task_2_in_paper_1)).to be false
        expect(task_3_assignee.can?(:view, task_3_in_paper_2)).to be true
        expect(task_3_assignee.can?(:view, task_4_in_paper_2)).to be false
      end
    end

    context 'specifying a permission applies_to wider than the assignment' do
      before do
        role_task_assignee.permissions.create! action: 'view', applies_to: 'Paper'
        role_task_assignee.permissions.create! action: 'view', applies_to: 'Journal'
      end

      it 'does expands the applies_to of permission check when the applies_to is paper' do
        expect(task_1_assignee.can?(:view, paper_1)).to be true
      end

      it 'does expands the applies_to of permission check when the applies_to is journal' do
        expect(task_1_assignee.can?(:view, journal)).to be true
      end
    end

  end

end
