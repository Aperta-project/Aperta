require 'rails_helper'

describe TahiStandardTasks::PaperAdminTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe "updating paper admin" do
    let(:sally) { create :user }
    let(:bob) { create :user }

    let(:paper) { create(:paper, :with_tasks) }
    let!(:old_role) { create(:paper_role, old_role: 'admin', user: bob, paper: paper) } # make bob an admin for the paper
    let(:phase) { paper.phases.first }
    let(:task) do
      TahiStandardTasks::PaperAdminTask.create(
        paper: paper,
        phase: phase,
        admin_id: bob.id,
        old_role: "admin",
        title: "Assign Admin"
      )
    end

    context "when paper admin is changed" do
      it "will update paper and tasks" do
        expect(task).to receive(:update_paper_admin_and_tasks)
        # the admin was bob, change to sally
        task.admin_id = sally.id
        task.save
      end
    end

    context "when paper admin is not changed" do
      it "will not update paper or tasks" do
        expect(task).to_not receive(:update_paper_admin_and_tasks)
        # the admin stays bob, nothing should happen.
        task.save
      end
    end
  end
end
