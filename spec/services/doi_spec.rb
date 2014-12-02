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
end
