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

    let!(:child_question_bar) { FactoryGirl.create(:nested_question, ident: "bar", parent: question_foo) }
    let!(:child_answer_bar) { FactoryGirl.create(:nested_question_answer, owner: task, nested_question: child_question_bar) }
    #

    it "returns the answer for the question matching the given ident" do
      expect(task.answer_for("foo")).to eq(answer_foo)
    end

    it "can find nested questions using dot (.) path syntax" do
      expect(task.answer_for("foo.bar")).to eq(child_answer_bar)
    end

    context "and there is no answer for the given path" do
      it "returns nil" do
        expect(task.answer_for("unknown-path")).to be(nil)
      end
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
end
