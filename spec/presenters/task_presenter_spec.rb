require 'spec_helper'

describe TaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let :task do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      Task.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first
    end

    it_behaves_like "all tasks, which have common attributes" do
      let(:card_name) { 'task' }
    end
  end
end
