require 'spec_helper'

describe FlowManagerData do
  let :admin do
    FactoryGirl.create :user, :admin
  end

  let! :paper do
    Paper.create! short_title: 'foo bar',
      title: "Paper title",
      abstract: "Paper abstract",
      body: "Paper body",
      authors: [{ first_name: 'Agnes', last_name: 'Stuart', affiliation: 'ABCMouse, Inc.', email: 'agnes@example.com' }],
      journal: Journal.create!
  end

  let(:tech_check_task) { paper.tasks.where(title: "Tech Check").first }
  let(:flow_manager_data) { FlowManagerData.new(admin) }

  describe "#incomplete_tasks" do
    it "returns incomplete assigned tasks grouped by paper" do
      tech_check_task.update!(assignee: admin)
      expect(flow_manager_data.incomplete_tasks).to match_array([[paper, [tech_check_task]]])
    end

    context "when the task is completed" do
      it "doesn't return that task" do
        tech_check_task.update!(assignee: admin, completed: true)
        expect(flow_manager_data.incomplete_tasks).to be_empty
      end
    end

    context "when the task is not assigned to the given user" do
      it "doesn't return that task" do
        expect(flow_manager_data.incomplete_tasks).to be_empty
      end
    end
  end

  describe "#complete_tasks" do
    it "returns completed and assigned tasks grouped by paper" do
      tech_check_task.update!(assignee: admin, completed: true)
      expect(flow_manager_data.complete_tasks).to match_array([[paper, [tech_check_task]]])
    end

    context "when the task is incomplete" do
      it "doesn't return that task" do
        tech_check_task.update!(assignee: admin)
        expect(flow_manager_data.complete_tasks).to be_empty
      end
    end

    context "when the task is not assigned to the given user" do
      it "doesn't return that task" do
        tech_check_task.update!(completed: true)
        expect(flow_manager_data.complete_tasks).to be_empty
      end
    end
  end

  describe "#paper_admin_tasks" do
    let(:paper_admin_task) { PaperAdminTask.first }

    it "returns papers for which the given user is a paper admin of" do
      paper_admin_task.update! assignee: admin
      expect(flow_manager_data.paper_admin_tasks).to match_array([[paper, []]])
    end

    context "when the paper isn't assigned to the given user" do
      it "doesn't return that paper" do
        expect(flow_manager_data.paper_admin_tasks).to be_empty
      end
    end
  end

  describe "#unassigned_papers" do
    context "when the given user is a journal admin" do
      before :each do
        JournalRole.create! journal: paper.journal, user: admin, admin: true
      end

      it "returns the paper admin task with the paper" do
        expect(flow_manager_data.unassigned_papers).to match_array([[paper, [PaperAdminTask.first]]])
      end
    end

    context "when the user isn't the journal's admin" do
      it "doesn't return the paper" do
        expect(flow_manager_data.unassigned_papers).to be_empty
      end
    end
  end

  describe "#flows" do
    it "returns a hash of flows" do
      allow(flow_manager_data).to receive(:incomplete_tasks).and_return(1)
      allow(flow_manager_data).to receive(:complete_tasks).and_return(2)
      allow(flow_manager_data).to receive(:paper_admin_tasks).and_return(3)
      allow(flow_manager_data).to receive(:unassigned_papers).and_return(4)

      flows = ['Up for grabs', 'My Tasks', 'My Papers', 'Done']
      settings = double(:settings, flows: flows)
      expect(admin).to receive(:user_settings).and_return(settings)
      table_data = [
        {title: 'Up for grabs', tasks: 4},
        {title: 'My Tasks', tasks: 1},
        {title: 'My Papers', tasks: 3},
        {title: 'Done', tasks: 2}
      ]

      flow_manager_data.flows.each do |flow|
        table_data.each do |data|
          if flow.name == data[:title]
            expect(flow.tasks).to eq(data[:tasks])
          end
        end
      end
    end
  end
end
