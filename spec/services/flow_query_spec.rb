require 'spec_helper'

describe FlowQuery do
  let(:user) { FactoryGirl.create :user }

  let(:journal) { FactoryGirl.create(:journal) }

  let(:paper) do
    FactoryGirl.create(:paper,
      journal: journal,
      user: user)
  end
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }


  describe "#tasks" do
    it "For 'My tasks' returns incomplete tasks that the user is participating in" do
      incomplete_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [user])
      complete_task = FactoryGirl.create(:task, phase: phase, completed: true, participants: [user])
      unrelated_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [])

      expect(FlowQuery.new(user, 'My tasks').tasks).to match_array [incomplete_task]
    end

    it "For 'Done' returns completed tasks that the user is participating in" do
      incomplete_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [user])
      complete_task = FactoryGirl.create(:task, phase: phase, completed: true, participants: [user])
      unrelated_task = FactoryGirl.create(:task, phase: phase, completed: false, participants: [])

      expect(FlowQuery.new(user, 'Done').tasks).to match_array [complete_task]
    end

    it "For 'My papers' it returns PaperAdminTasks on papers in which the user has an Admin role" do
      paper_admin_task = FactoryGirl.create(:paper_admin_task, phase: phase)
      make_user_paper_admin(user, paper)

      other_task_same_paper = FactoryGirl.create(:task, phase: phase)
      paper_admin_task_other_paper = FactoryGirl.create(:paper_admin_task)

      expect(FlowQuery.new(user, 'My papers').tasks).to match_array [paper_admin_task]
    end

    # this is how it is now but it makes no sense to be the same for both

    context "When scoped to journals the user has a role in" do
      it "For 'Up for grabs' returns incomplete, unassigned PaperAdminTasks for journals the user has a role in." do
        valid_task = FactoryGirl.create(:paper_admin_task, phase: phase, completed: false)
        assign_journal_role(journal, user, :editor)
        other_task_same_journal = FactoryGirl.create(:task, phase: phase)

        other_paper_admin_task = FactoryGirl.create(:paper_admin_task)
        expect(FlowQuery.new(user, 'Up for grabs', true).tasks).to match_array [valid_task]

        valid_task.update(completed: true)
        expect(FlowQuery.new(user, 'Up for grabs', true).tasks).to be_empty
      end
    end

    context "When unscoped" do
      it "For 'Up for grabs' returns incomplete, unassigned PaperAdminTasks for any journal" do
        valid_task = FactoryGirl.create(:paper_admin_task, phase: phase, completed: false)
        assign_journal_role(journal, user, :editor)

        other_paper_admin_task = FactoryGirl.create(:paper_admin_task)

        expect(FlowQuery.new(user, 'Up for grabs').tasks).to match_array [valid_task, other_paper_admin_task]
      end
    end
  end
end
