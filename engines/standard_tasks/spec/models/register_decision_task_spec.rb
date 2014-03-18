require 'spec_helper'

describe StandardTasks::RegisterDecisionTask do
  describe "defaults" do
    subject(:task) { StandardTasks::RegisterDecisionTask.new }
    specify { expect(task.title).to eq 'Register Decision' }
    specify { expect(task.role).to eq 'editor' }
  end

  context "letters" do
    let(:paper) { Paper.create! short_title: 'hello',
                  title: "Crazy stubbing tests on rats",
                  journal: Journal.create! }
    let(:task) { StandardTasks::RegisterDecisionTask.create! phase: paper.phases.first }

    before do
      user = double(:last_name, last_name: 'Mazur')
      editor = double(:full_name, full_name: 'Andi Plantenberg')
      journal = double(:name, name: 'PLOS Yeti')
      allow(paper).to receive(:user).and_return(user)
      allow(paper).to receive(:editor).and_return(editor)
      allow(paper).to receive(:journal).and_return(journal)
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#accept_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.accept_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.accept_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.accept_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.accept_letter).to match(/Crazy stubbing tests on rats/)
      end
    end

    describe "#revise_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.revise_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.revise_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.revise_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.revise_letter).to match(/Crazy stubbing tests on rats/)
      end

    end
    describe "#reject_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.reject_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.reject_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.reject_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.reject_letter).to match(/Crazy stubbing tests on rats/)
      end
    end

    context "when the editor hasn't been assigned yet" do
      it "returns 'Editor not assigned'" do
        allow(paper).to receive(:editor).and_return(nil)
        expect(task.accept_letter).to match(/Editor not assigned/)
        expect(task.accept_letter).to_not match(/Andi Plantenberg/)
      end
    end
  end

  describe "save and retrieve paper decision and decision letter" do
    let(:task) { StandardTasks::RegisterDecisionTask.new }
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
