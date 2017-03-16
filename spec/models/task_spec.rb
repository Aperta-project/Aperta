require 'rails_helper'

describe Task do
  it_behaves_like 'is not snapshottable'

  describe ".without" do
    let!(:tasks) do
      Array.new(2) do
        Task.create! title: "Paper Admin",
                     completed: true,
                     phase_id: 3,
                     paper_id: 99
      end
    end

    it "excludes task" do
      expect(Task.count).to eq(2)
      expect(Task.without(tasks.last).count).to eq(1)
    end
  end

  describe '#add_participant' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
    let(:user) { FactoryGirl.create :user }

    it 'adds the user as a participant on the task' do
      expect do
        task.add_participant(user)
      end.to change(task.participants, :count).by(1)
    end

    it 'does not add them more than once' do
      expect do
        task.add_participant(user)
        task.add_participant(user)
        task.add_participant(user)
      end.to change(task.participants, :count).by(1)
    end
  end

  describe '#assignments' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, :with_stubbed_associations }

    before do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    context 'on #destroy' do
      it 'destroy assignments' do
        expect do
          task.destroy!
        end.to change { task.assignments.count }.by(-1)
      end
    end
  end

  describe '#participations' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.task_participant_role,
        assigned_to: task
      )
    end

    let!(:other_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    it 'returns the assignments where the role is participant' do
      expect(task.participations).to contain_exactly(participant_assignment)
      expect(task.participations).to_not include(other_assignment)
    end
  end

  describe '#participants' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.task_participant_role,
        assigned_to: task
      )
    end

    let!(:other_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: FactoryGirl.create(:role),
        assigned_to: task
      )
    end

    it 'returns the users who are assigned to the task as a participant' do
      expect(task.participants).to contain_exactly(participant_assignment.user)
      expect(task.participants).to_not include(other_assignment.user)
    end
  end

  describe '#permission_requirements' do
    subject(:task) { FactoryGirl.create :ad_hoc_task, :with_stubbed_associations }

    before do
      FactoryGirl.create(:permission_requirement, required_on: task)
    end

    context 'on #destroy' do
      it 'destroy assignments' do
        expect do
          task.destroy!
        end.to change { task.permission_requirements.count }.by(-1)
      end
    end
  end

  describe "#invitations" do
    let(:paper) { FactoryGirl.create :paper }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let!(:invitation) { FactoryGirl.create :invitation, task: task }

    context "on #destroy" do
      it "destroy invitations" do
        expect do
          task.destroy!
        end.to change { Invitation.count }.by(-1)
      end
    end
  end

  describe "Answerable#answers" do
    it "destroys answers on destroy" do
      task = FactoryGirl.create(:ad_hoc_task)
      answer = FactoryGirl.create(:answer, owner: task)
      expect(task.answers.pluck(:id)).to contain_exactly(answer.id)

      task.destroy
      expect(Answer.count).to eq(0)
    end
  end

  describe "Answerable#answer_for" do
    subject(:task) { FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations) }
    let!(:answer_foo) do
      FactoryGirl.create(
        :answer,
        owner: task,
        value: "the answer",
        card_content: FactoryGirl.create(:card_content, ident: "foo")
      )
    end

    it "returns the answer for the question matching the given ident" do
      expect(task.answer_for("foo")).to eq(answer_foo)
    end

    it "returns nil if there is no answer for the given ident" do
      expect(task.answer_for("unknown-ident")).to be(nil)
    end
  end

  describe 'Task.descendants' do
    it 'includes a new subclass of Task' do
      new_task = Class.new(Task)
      expect(Task.descendants).to include(new_task)
    end

    it 'returns all the tasks' do
      tasks_from_source = Dir[Rails.root.join('**/*.rb')]
                          .select { |path| path.match(%r{models/.*task.rb}) }
                          .reject { |path| path.match(/concerns/) }
                          .reject { |path| path.match(%r{models/task.rb}) }
                          .map { |path| path.match(%r{models/(.*).rb})[1] }

      tasks = Task.descendants.map { |c| c.to_s.underscore }
      expect(tasks).to include(*tasks_from_source)
    end

    it 'works across reload' do
      # TODO: This tests wreaks havoc on classes that are nested deep in engines
      # app/subscribers.
      skip
      expect do
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      end.not_to change { Task.descendants.count }
    end
  end

  describe 'Task.safe_constantize' do
    it 'fails with Task' do
      expect { Task.safe_constantize('Task') }
        .to raise_error(/constantize disallowed/)
    end

    it 'works with Task descendants' do
      expect(Task.safe_constantize('TahiStandardTasks::TaxonTask'))
        .to eq(TahiStandardTasks::TaxonTask)
    end

    it 'fails with non-tasks' do
      expect { Task.safe_constantize('User') }
        .to raise_error(/constantize disallowed/)
    end
  end

  describe "#can_change?: associations can use this method to update based on task" do
    let(:task) do
      FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations)
    end

    it "returns true" do
      expect(task.can_change?(double)).to eq(true)
    end
  end
end
