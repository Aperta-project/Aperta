require 'spec_helper'

describe PaperReviewerTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let :assignee do
      User.create! username: 'worker',
        first_name: 'Busy', last_name: 'Bee',
        password: 'password', password_confirmation: 'password',
        email: 'worker@example.org'
    end

    let :reviewer do
      User.create! username: 'reviewer',
        first_name: 'Rachel', last_name: 'Reviewer',
        password: 'password', password_confirmation: 'password',
        email: 'reviewer@example.org'
    end

    let(:task) do
      author = User.create! username: 'adam',
                            password: 'password', password_confirmation: 'password',
                            email: 'adam@example.org'
      paper = Paper.create! title: "Foo bar",
        short_title: "Foo",
        journal: Journal.create!,
        user: author
      task = PaperReviewerTask.create! completed: true,
        phase: paper.task_manager.phases.first,
        assignee: assignee
      allow(task).to receive(:paper).and_return paper
      allow(task).to receive(:assignees).and_return [assignee]
      allow(task).to receive(:reviewer_ids).and_return [reviewer.id]
      allow(task).to receive(:reviewers).and_return [reviewer]
      task
    end

    subject(:data_attributes) { PaperReviewerTaskPresenter.new(task).data_attributes }

    it_behaves_like "all tasks, which have common attributes" do
      before { pending }
      let(:card_name) { 'paper-reviewer' }
      let(:assignee_id) { assignee.id }
      let(:assignees) { [user_select_hash(assignee)] }
    end

    it "returns custom data for paper reviewer task" do
      expect(data_attributes).to include({
        'reviewerIds' => [reviewer.id],
        'reviewers'   => [user_select_hash(reviewer)],
        'refresh-on-close' => true
      })
    end
  end
end
