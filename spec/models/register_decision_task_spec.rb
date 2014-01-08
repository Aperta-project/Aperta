require 'spec_helper'

describe RegisterDecisionTask do
  describe "defaults" do
    subject(:task) { RegisterDecisionTask.new }
    specify { expect(task.title).to eq 'Register Decision' }
    specify { expect(task.role).to eq 'editor' }
  end

  describe "save and retrieve paper decision and decision letter" do
    let(:task) { RegisterDecisionTask.new }
    let(:paper) { Paper.create! short_title: 'hello',
                  journal: Journal.create!,
                  decision: "Accepted",
                  decision_letter: 'Lorem Ipsum' }

    before do
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#paper_decision" do
      it "returns paper's decision" do
        expect(task.paper_decision).to eq("Accepted")
      end
    end

    describe "#paper_decision=" do
      it "returns paper's decision" do
        task.paper_decision = "Rejected"
        expect(task.paper_decision).to eq("Rejected")
      end
    end

    describe "#paper_decision_letter" do
      it "returns paper's decision" do
        expect(task.paper_decision_letter).to eq("Lorem Ipsum")
      end
    end

    describe "#paper_decision_letter=" do
      it "returns paper's decision" do
        task.paper_decision_letter = "Rejecting because I can"
        expect(task.paper_decision_letter).to eq("Rejecting because I can")
      end
    end
  end

end
