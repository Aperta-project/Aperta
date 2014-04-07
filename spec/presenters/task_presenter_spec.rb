require 'spec_helper'

class FakeTaskPresenter
  def initialize *args
  end
end

class FakeTask
end

describe TaskPresenter do
  include Rails.application.routes.url_helpers

  describe ".for" do
    let(:task) { FakeTask.new }
    specify { expect(TaskPresenter.for(task)).to be_a FakeTaskPresenter }
  end

  describe "#data_attributes" do
    let :journal_admin do
      User.create! username: 'worker',
        first_name: 'Andi', last_name: 'Admin',
        password: 'password', password_confirmation: 'password',
        email: 'worker@example.org'
    end

    let :task do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      Task.create! title: "Verify Signatures",
        assignee: journal_admin,
        completed: true,
        body: 'Too many muscles!',
        role: 'admin',
        phase: paper.task_manager.phases.first
    end

    let! :journal_role do
      JournalRole.create! user: journal_admin, journal: task.journal, admin: true
    end

    it_behaves_like "all tasks, which have common attributes" do
      before { pending }
      let(:card_name) { 'task' }
    end

    context "when the paper title is missing" do
      let :task do
        paper = Paper.create! short_title: "Foo", journal: Journal.create!
        Task.create! title: "Verify Signatures",
          assignee: journal_admin,
          completed: true,
          body: 'Too many muscles!',
          role: 'admin',
          phase: paper.task_manager.phases.first
      end

      it "returns short_title instead of nil" do
        expect(TaskPresenter.for(task).data_attributes).to include(
          'paperTitle' => task.paper.short_title,
        )
      end
    end
  end
end
