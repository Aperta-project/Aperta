require 'spec_helper'

describe Paper do
  describe "initialization" do
    describe "paper_type" do
      context "when no paper_type is specified" do
        it "defaults to research" do
          expect(Paper.new.paper_type).to eq 'research'
        end
      end

      context "when paper_type is the empty string" do
        it "defaults to research" do
          expect(Paper.new(paper_type: '').paper_type).to eq 'research'
        end
      end

      context "when paper_type is specified" do
        it "uses specified paper_type" do
          expect(Paper.new(paper_type: 'foobar').paper_type).to eq 'foobar'
        end
      end
    end

    describe "declarations" do
      it "initializes default declarations" do
        default_declarations = [
          Declaration.new(question: 'Question 1'),
          Declaration.new(question: 'Question 2'),
          Declaration.new(question: 'Question 3')
        ]
        Declaration.stub(:default_declarations).and_return default_declarations

        paper = Paper.new
        expect(paper.declarations).to match_array default_declarations
      end

      context "when declarations are specified" do
        it "uses provided declarations" do
          declarations = [Declaration.new(question: 'Question')]
          paper = Paper.new declarations: declarations
          expect(paper.declarations).to match_array declarations
        end
      end
    end
  end

  describe "validations" do
    describe "paper_type" do
      it "must be one of Paper::PAPER_TYPES" do
        paper = Paper.new
        Paper::PAPER_TYPES.each do |type|
          paper.paper_type = type
          expect(paper).to be_valid
        end
        paper.paper_type = 'invalid paper type'
        expect(paper).to have(1).error_on :paper_type
      end
    end
  end

  describe "scopes" do
    let(:ongoing_paper)   { Paper.create! submitted: false }
    let(:submitted_paper) { Paper.create! submitted: true  }

    describe ".submitted" do
      it "returns submitted papers only" do
        expect(Paper.submitted).to_not include(ongoing_paper)
        expect(Paper.submitted).to include(submitted_paper)
      end
    end

    describe ".ongoing" do
      it "returns submitted papers only" do
        expect(Paper.ongoing).to_not include(submitted_paper)
        expect(Paper.ongoing).to include(ongoing_paper)
      end
    end
  end
end
