require 'rails_helper'

describe Task do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe ".without" do
    let!(:tasks) do
      2.times.map do
        Task.create! title: "Paper Admin",
          completed: true,
          role: 'admin',
          phase_id: 3
      end
    end

    it "excludes task" do
      expect(Task.count).to eq(2)
      expect(Task.without(tasks.last).count).to eq(1)
    end
  end

  describe "#invitations" do
    let(:phase) { FactoryGirl.create :phase }
    let(:task) { FactoryGirl.create :invitable_task, phase: phase }
    let!(:invitation) { FactoryGirl.create :invitation, task: task }

    context "on #destroy" do
      it "destroy invitations" do
        expect {
          task.destroy!
        }.to change { Invitation.count }.by(-1)
      end
    end
  end

  describe "#questions" do
    it "destroys questions on destroy" do
      task = FactoryGirl.create(:task, :with_questions)
      question_ids = task.questions.pluck :id
      expect(question_ids).to have_at_least(1).id

      expect {
        task.destroy
      }.to change {
        Question.where(id: question_ids).count
      }.from(question_ids.count).to(0)
    end
  end

  describe "#can_change?: associations can use this method to update based on task" do
    let(:task) {
      Task.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase_id: 3
    }

    it "returns true" do
      expect(task.can_change? double).to eq(true)
    end
  end

  describe "#notify_completion" do
    context "when being completed" do
      let!(:task) { FactoryGirl.create(:task, completed: false) }

      it "fires event if being marked as complete" do
        expect(Notifier).to receive(:notify).with(event: "task:completed", data: { record: task })
        task.completed = true
        task.save
      end
    end

    context "when being uncompleted" do
      let!(:task) { FactoryGirl.create(:task, completed: true) }

      it "does not fire event" do
        expect(Notifier).to_not receive(:notify)
        task.completed = false
        task.save
      end
    end

    context "when completion status not changing" do
      let!(:task) { FactoryGirl.create(:task, completed: false) }

      it "does not fire event" do
        expect(Notifier).to_not receive(:notify)
        task.title = "completion did not change"
        task.save
      end
    end
  end
end
