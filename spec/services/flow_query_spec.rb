require 'rails_helper'

describe FlowQuery do
  let(:user_journal) do
    FactoryGirl.create(:journal, :with_roles_and_permissions)
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:site_admin) { FactoryGirl.create(:user, :site_admin) }

  let(:paper) do
    FactoryGirl.create(:paper,
                       journal: user_journal,
                       creator: user)
  end
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }

  before do
    assign_journal_role(user_journal, user, :editor)
  end

  describe "#tasks" do
    context "query is empty" do
      let!(:task) { FactoryGirl.create(:task, paper: paper, phase: phase) } # this test always passes unless a Task exists...
      let(:query) { {} }
      let(:flow) { FactoryGirl.build(:flow, journal: user_journal, query: query) }

      it "returns an empty relation" do
        tasks = FlowQuery.new(user, flow).tasks
        expect(tasks).to be_empty
      end
    end

    context "scoping tasks by journal" do
      let!(:user_task) { FactoryGirl.create(:task, paper: paper, phase: phase, completed: true, participants: [user]) }
      let!(:other_paper_on_other_journal) do
        FactoryGirl.create(:paper, :with_integration_journal)
      end
      let!(:other_task) do
        FactoryGirl.create(
          :task,
          paper: other_paper_on_other_journal,
          completed: true,
          participants: [user]
        )
      end

      context "for a site admin" do
        context "for a default flow" do
          it "does not scope tasks" do
            flow = FactoryGirl.build(:flow, :default, query: {state: :completed})
            tasks = FlowQuery.new(site_admin, flow).tasks
            expect(tasks).to include(user_task)
            expect(tasks).to include(other_task)
          end
        end

        context "for a journal-specific flow" do
          it "scopes the tasks to the flow's journal" do
            flow = FactoryGirl.build(:flow, query: {state: :completed}, journal: user_journal)
            tasks = FlowQuery.new(site_admin, flow).tasks

            expect(tasks).to include(user_task)
            expect(tasks).to_not include(other_task)
          end
        end
      end

      context "for a non-site-admin" do
        context "for a default flow" do
          it "scopes tasks to the user's journals" do
            flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {state: :completed})
            tasks = FlowQuery.new(user, flow).tasks

            expect(tasks).to include(user_task)
            expect(tasks).to_not include(other_task)
          end
        end

        context "for a journal-specific flow" do
          it "scopes the tasks to the flow's journal" do
            flow = FactoryGirl.build(:flow, query: {state: :completed}, journal: user_journal)
            tasks = FlowQuery.new(user, flow).tasks

            expect(tasks).to include(user_task)
            expect(tasks).to_not include(other_task)
          end
        end
      end
    end

    context "scoping tasks by assigned" do
      let!(:assigned_task) { FactoryGirl.create(:task, participants: [user], paper: paper, phase: phase, completed: true) }
      let!(:unassigned_task) { FactoryGirl.create(:task, participants: [], paper: paper, phase: phase, completed: true) }
      context "assigned query is true" do
        it "scopes tasks to assigned to the user" do
          flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {assigned: true})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to include(assigned_task)
          expect(tasks).to_not include(unassigned_task)
        end
      end

      context "assigned query is false" do
        it "scopes tasks to unassigned" do
          flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {assigned: false})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to_not include(assigned_task)
          expect(tasks).to include(unassigned_task)
        end
      end
    end

    context "scoping tasks by state" do
      let!(:complete) { FactoryGirl.create(:task, completed: true, paper: paper, phase: phase, participants: [user]) }
      let!(:incomplete) { FactoryGirl.create(:task, completed: false, paper: paper, phase: phase, participants: [user]) }

      context "state query is complete" do
        it "scopes tasks to completed task" do
          flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {state: :completed})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to include(complete)
          expect(tasks).to_not include(incomplete)
        end
      end

      context "state query is incomplete" do
        it "scopes tasks to incomplete task" do
          flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {state: :incomplete})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to_not include(complete)
          expect(tasks).to include(incomplete)
        end
      end
    end

    context "scoping tasks by old_role" do
      let!(:admin_task) { FactoryGirl.create(:task, paper: paper, phase: phase, participants: [user], old_role: "Admin") }
      let!(:generic_task) { FactoryGirl.create(:task, paper: paper, phase: phase, participants: [user]) }

      it "it scopes tasks by old_role if old_role is given" do
        flow = FactoryGirl.build(:flow, :default, title: 'My tasks', query: {old_role: "Admin"})
        tasks = FlowQuery.new(user, flow).tasks

        expect(tasks).to include(admin_task)
        expect(tasks).to_not include(generic_task)
      end
    end

    context "scoping tasks by type" do
      let!(:admin_task) { FactoryGirl.create(:paper_admin_task, paper: paper) }
      let!(:generic_task) { FactoryGirl.create(:task, paper: paper) }

      it "scopes tasks by type" do
        flow = FactoryGirl.build(:flow, :default, query: {type: "TahiStandardTasks::PaperAdminTask"})
        tasks = FlowQuery.new(site_admin, flow).tasks

        expect(tasks).to include(admin_task)
        expect(tasks).to_not include(generic_task)
      end
    end

    context "default scopes" do
      let!(:up_for_grabs) do
        FactoryGirl.create(
          :task,
          paper: paper,
          phase: phase,
          completed: false,
          participants: []
        )
      end
      let!(:my_tasks) do
        FactoryGirl.create(
          :task,
          paper: paper,
          phase: phase,
          completed: false,
          participants: [user]
        )
      end
      let!(:done) do
        FactoryGirl.create(
          :task,
          paper: paper,
          phase: phase,
          completed: true,
          participants: [user]
        )
      end

      context "Up for grabs" do
        it "returns tasks that are up for grabs" do
          flow = FactoryGirl.build(:flow, :default, query: {assigned: false, state: :incomplete})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to include(up_for_grabs)
          expect(tasks.count).to eq(1)
        end
      end

      context "My tasks" do
        it "returns tasks that are 'my tasks'" do
          flow = FactoryGirl.build(:flow, :default, query: {state: :incomplete, assigned: true})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to include(my_tasks)
          expect(tasks.count).to eq(1)
        end
      end

      context "Done" do
        it "returns tasks that are done" do
          flow = FactoryGirl.build(:flow, :default, query: {state: :completed, assigned: true})
          tasks = FlowQuery.new(user, flow).tasks

          expect(tasks).to include(done)
          expect(tasks.count).to eq(1)
        end
      end
    end
  end
end
