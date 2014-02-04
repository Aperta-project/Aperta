require 'spec_helper'

describe TechCheckTask do
  describe "defaults" do
    subject(:task) { TechCheckTask.new }
    specify { expect(task.title).to eq 'Tech Check' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "#assignees" do
    let(:task) { TechCheckTask.new phase: paper.task_manager.phases.first }
    let(:paper) { Paper.create! short_title: 'hello',
                  journal: Journal.create!,
                  decision: "Accepted",
                  decision_letter: 'Lorem Ipsum' }

    it "returns admins for this paper's journal" do
      admins = double(:admins)
      expect(User).to receive(:admins).and_return admins
      expect(task.assignees).to eq admins
    end
  end
end
