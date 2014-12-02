require 'spec_helper'

describe Doi do

  describe ".valid?" do
    context "with a doi" do
      let(:doi) { 'any/thing.1' }
      it "returns true" do
        expect(described_class.valid? doi).to eq true
      end
    end

    context "without a doi" do
      it "returns false" do
        expect(described_class.valid? nil).to eq false
      end
    end

    context "with an invalid doi" do
      it "returns false" do
        expect(described_class.valid? "monkey").to eq false
      end
    end
  end

  describe "initialization" do
    context "with a journal" do
      let(:journal) { create :journal }
      it "assigns a journal as @journal" do
        expect(described_class.new(journal: journal).journal).to eq journal
      end
    end

    context "without a journal" do
      it "raises an exception" do
        expect {
          described_class.new(nil)
        }.to raise_error ArgumentError, "missing keyword: journal"
      end
    end
  end
end
