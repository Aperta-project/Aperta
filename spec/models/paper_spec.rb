require 'spec_helper'

describe Paper do
  describe "initialization" do
    describe "paper_type" do
      context "when no paper_type is specified" do
        it "defaults to research" do
          expect(Paper.new.paper_type).to eq 'research'
        end
      end

      context "when paper_type is specified" do
        it "uses specified paper_type" do
          expect(Paper.new(paper_type: 'foobar').paper_type).to eq 'foobar'
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
end
