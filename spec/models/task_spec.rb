require 'rails_helper'

describe Task do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe ".without" do
    let!(:tasks) do
      2.times.map do
        Task.create! title: "Paper Admin",
          completed: true,
          old_role: 'admin',
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
    subject(:task) { FactoryGirl.create :task }
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
    subject(:task) { FactoryGirl.create :task }

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
    subject(:task) { FactoryGirl.create :task }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.participant_role,
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
    subject(:task) { FactoryGirl.create :task }

    let!(:participant_assignment) do
      Assignment.create!(
        user: FactoryGirl.create(:user),
        role: task.journal.participant_role,
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

  describe "#invitations" do
    let(:paper) { FactoryGirl.create :paper }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let!(:invitation) { FactoryGirl.create :invitation, task: task }

    context "on #destroy" do
      it "destroy invitations" do
        expect {
          task.destroy!
        }.to change { Invitation.count }.by(-1)
      end
    end
  end

  describe "#nested_question_answers" do
    it "destroys nested_question_answers on destroy" do
      task = FactoryGirl.create(:task, :with_nested_question_answers)
      nested_question_answer_ids = task.nested_question_answers.pluck :id
      expect(nested_question_answer_ids).to have_at_least(1).id

      expect {
        task.destroy
      }.to change {
        NestedQuestionAnswer.where(id: nested_question_answer_ids).count
      }.from(nested_question_answer_ids.count).to(0)
    end
  end

  describe "#answer_for" do
    subject(:task) { FactoryGirl.create(:task) }
    let!(:question_foo) { FactoryGirl.create(:nested_question, ident: "foo") }
    let!(:answer_foo) { FactoryGirl.create(:nested_question_answer, owner: task, value: "the answer", nested_question: question_foo) }

    it "returns the answer for the question matching the given ident" do
      expect(task.answer_for("foo")).to eq(answer_foo)
    end

    context "and there is no answer for the given ident" do
      it "returns nil" do
        expect(task.answer_for("unknown-ident")).to be(nil)
      end
    end
  end

  describe 'Task.all_task_types' do
    it 'includes a new subclass of Task' do
      class NewTask < Task; end
      expect(Task.all_task_types).to include(NewTask)
    end

    it 'returns all the tasks' do
      tasks_from_source = Dir[Rails.root.join('**/*.rb')]
                          .select { |path| path.match(%r{models/.*task.rb}) }
                          .reject { |path| path.match(/concerns/) }
                          .map { |path| path.match(%r{models/(.*).rb})[1] }

      tasks = Task.all_task_types.map { |c| c.to_s.underscore }.sort -
              %w(mock_metadata_task test_task invitable_task new_task)
      expect(tasks).to eq((tasks_from_source).sort)
    end

    it 'works across reload' do
      # TODO: This tests wreaks havoc on classes that are nested deep in engines
      # app/subscribers.
      skip
      expect do
        ActionDispatch::Reloader.cleanup!
        ActionDispatch::Reloader.prepare!
      end.not_to change { Task.all_task_types.count }
    end
  end

  describe 'Task.safe_constantize' do
    it 'works with Task' do
      expect(Task.safe_constantize('Task')).to eq(Task)
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
    let(:task) {
      Task.create! title: "Paper Admin",
        completed: true,
        old_role: 'admin',
        phase_id: 3,
        paper_id: 99
    }

    it "returns true" do
      expect(task.can_change? double).to eq(true)
    end
  end
end
