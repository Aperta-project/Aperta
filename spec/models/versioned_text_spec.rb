require 'rails_helper'

describe VersionedText, focus: true do
  let(:versioned_text) { FactoryGirl.create :versioned_text }

  describe "#update" do
    context "No copy on edit necessary" do
      it "simply updates" do
        versioned_text.update!(text: "foo")
        expect(VersionedText.count()).to eq(1)
      end
    end

    context "Copy on edit" do
      let(:versioned_text) do
        FactoryGirl.create(:versioned_text, :copy_on_edit)
      end

      it "makes a copy" do
        versioned_text.update!(text: "foo")
        expect(VersionedText.count()).to eq(2)
      end

      it "clears the copy on edit flag" do
        versioned_text.update!(text: "foo")
        expect(versioned_text.copy_on_edit).to eq(false)
      end
    end
  end

  describe "#major_version!" do
    it "increments major version" do
      versioned_text.major_version!
      expect(versioned_text.major_version).to eq(1)
    end

    it "zeroes the minor version" do
      versioned_text.major_version!
      expect(versioned_text.minor_version).to eq(0)
    end

    it "sets copy on edit flag" do
      versioned_text.major_version!
      expect(versioned_text.copy_on_edit).to eq(true)
    end
  end
end
