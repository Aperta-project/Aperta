require 'spec_helper'

describe FlowQuery do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:user) { FactoryGirl.create :user }

  let(:paper) do
    FactoryGirl.create(:paper,
                       journal: journal,
                       creator: user)
  end
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }

  before do
    assign_journal_role(journal, user, :editor)
  end

  describe "#tasks" do
    it "For 'My tasks' returns incomplete tasks that the user is participating in" do
      role_flow = RoleFlow.where(title: 'My tasks', query: [:incomplete, :assigned], default: true).first_or_create
      incomplete_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [user])
      complete_task = FactoryGirl.create(:task, phase: phase, completed: true, participants: [user])
      unrelated_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [])

      expect(FlowQuery.new(user, role_flow).tasks).to match_array [incomplete_task]
    end

    it "For 'Done' returns completed tasks that the user is participating in" do
      role_flow = RoleFlow.where(title: 'Done', query: [:completed, :assigned], default: true).first_or_create
      incomplete_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [user])
      complete_task = FactoryGirl.create(:task, phase: phase, completed: true, participants: [user])
      unrelated_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [])

      expect(FlowQuery.new(user, role_flow).tasks).to match_array [complete_task]
    end

    it "For 'My papers' it returns PaperAdminTasks on papers in which the user has an Admin role" do
      role_flow = RoleFlow.where(title: 'My papers', query: [:admin], default: true).first_or_create
      paper_admin_task = FactoryGirl.create(:paper_admin_task, phase: phase)
      make_user_paper_admin(user, paper)

      other_task_same_paper = FactoryGirl.create(:task, phase: phase)
      paper_admin_task_other_paper = FactoryGirl.create(:paper_admin_task)

      expect(FlowQuery.new(user, role_flow).tasks).to match_array [paper_admin_task]
    end

    it "For 'Up for grabs' returns incomplete, unassigned PaperAdminTasks for journals the user has a role in." do
      role_flow = RoleFlow.where(title: 'Up for grabs', query: [:unassigned, :incomplete, :admin], default: true).first_or_create
      valid_task = FactoryGirl.create(:paper_admin_task, phase: phase, completed: false)
      other_task_same_journal = FactoryGirl.create(:task, phase: phase)
      other_paper_admin_task = FactoryGirl.create(:paper_admin_task)

      expect(FlowQuery.new(user, role_flow).tasks).to match_array [valid_task]

      valid_task.update(completed: true)
      expect(FlowQuery.new(user, role_flow).tasks).to be_empty
    end

    context "When the user is a site admin" do
      let(:site_admin) { FactoryGirl.create :user, :site_admin }

      it "For 'Up for grabs' returns incomplete, unassigned PaperAdminTasks for any journal" do
        role_flow = RoleFlow.where(title: 'Up for grabs', query: [:unassigned, :incomplete, :admin], default: true).first_or_create
        valid_task = FactoryGirl.create(:paper_admin_task, phase: phase, completed: false)
        other_paper_admin_task = FactoryGirl.create(:paper_admin_task)

        expect(FlowQuery.new(site_admin, role_flow).tasks).to match_array [valid_task, other_paper_admin_task]
      end
    end
  end
end
