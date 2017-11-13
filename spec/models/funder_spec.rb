require "rails_helper"

describe Funder do
  context "basic attributes" do
    let(:repetition) { FactoryGirl.build(:repetition) }
    let(:card_content) { FactoryGirl.build(:card_content, ident: ident) }
    let(:answers) { [FactoryGirl.build(:answer, card_content: card_content, repetition: repetition, value: answer_value)] }
    let(:funder) { Funder.new(answers, repetition) }

    describe "#name" do
      let(:ident) { "funder--name" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.name).to eq(answer_value)
      end
    end

    describe "#grant_number" do
      let(:ident) { "funder--grant_number" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.grant_number).to eq(answer_value)
      end
    end

    describe "#website" do
      let(:ident) { "funder--website" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.website).to eq(answer_value)
      end
    end

    describe "#additional_comments" do
      let(:ident) { "funder--additional_comments" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.additional_comments).to eq(answer_value)
      end
    end

    describe "#influence" do
      let(:ident) { "funder--had_influence" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.influence).to eq(answer_value)
      end
    end

    describe "#influence_description" do
      let(:ident) { "funder--had_influence--role_description" }
      let(:answer_value) { "some words" }

      it "returns the correct answer value" do
        expect(funder.influence_description).to eq(answer_value)
      end
    end

    context "with a different repetition than the one attached to the answer" do
      let(:ident) { "funder--name" }
      let(:answer_value) { "some words" }

      let(:answers) { [FactoryGirl.build(:answer, card_content: card_content, repetition: FactoryGirl.build(:repetition), value: answer_value)] }

      it "returns no value" do
        expect(funder.name).to be_nil
      end
    end
  end

  describe "#funding_statement" do
    let(:funder) { Funder.new([], nil) }

    context "with only additional comments filled out" do
      before do
        allow(funder).to receive(:additional_comments).and_return("my comments")
      end

      it "returns only additional comments" do
        expect(funder.funding_statement).to eq("my comments")
      end
    end

    context "with name, grant number, and additional information filled out" do
      before do
        allow(funder).to receive(:name).and_return("my name")
        allow(funder).to receive(:website).and_return("my site")
        allow(funder).to receive(:grant_number).and_return("my grant number")
        allow(funder).to receive(:additional_comments).and_return("my comments")
        allow(funder).to receive(:influence).and_return(nil)
      end

      it "returns expected funding statement data" do
        expect(funder.funding_statement).to match(/my name my site \(grant number my grant number\)\. my comments/)
      end
    end

    context "without influence" do
      before do
        allow(funder).to receive(:name).and_return("my name")
        allow(funder).to receive(:influence).and_return(nil)
      end

      it "adds default influence statement" do
        expect(funder.funding_statement).to match(/funder had no role in study design/)
      end
    end
  end
end
