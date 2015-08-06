require 'rails_helper'

describe VersionedText do
  let(:versioned_text) { FactoryGirl.create :versioned_text, paper_id: 0 }

  describe "#new_major_version!" do
    it "creates a new major version while retaining the old" do
      versioned_text.new_major_version!
      expect(versioned_text.major_version).to eq(0)
      expect(versioned_text.minor_version).to eq(0)
      expect(VersionedText.where(paper_id: 0, major_version: 1, minor_version: 0).count).to eq(1)
    end
  end

  describe "#new_minor_version!" do
    it "creates a new minor version while retaining the old" do
      versioned_text.new_minor_version!
      expect(versioned_text.major_version).to eq(0)
      expect(versioned_text.minor_version).to eq(0)
      expect(VersionedText.where(paper_id: 0, major_version: 0, minor_version: 1).count).to eq(1)
    end
  end

  describe "#create" do
    it "should not allow creating multiple versions with the same number" do
      FactoryGirl.create(:versioned_text, paper_id: 1, major_version: 1, minor_version: 0)
      expect do
        FactoryGirl.create(:versioned_text, paper_id: 1, major_version: 1, minor_version: 0)
      end.to raise_exception(ActiveRecord::RecordNotUnique)
    end
  end
end
