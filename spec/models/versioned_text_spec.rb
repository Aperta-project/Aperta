require 'rails_helper'

describe VersionedText do
  let(:versioned_text) { FactoryGirl.create :versioned_text }
  let(:user) { FactoryGirl.create :user }

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
      versioned_text.major_version! user
      expect(versioned_text.major_version).to eq(1)
    end

    it "zeroes the minor version" do
      versioned_text.major_version! user
      expect(versioned_text.minor_version).to eq(0)
    end

    it "sets copy on edit flag" do
      versioned_text.major_version! user
      expect(versioned_text.copy_on_edit).to eq(true)
    end

    it "sets the submitting user" do
      versioned_text.major_version! user
      expect(versioned_text.submitting_user).to eq(user)
    end
  end

  describe '#version_string' do
    it "displays creator_name when submitting user is defined" do
      versioned_text.submitting_user = user
      versioned_text.updated_at = Time.local(2015, 12, 1, 10, 5, 0)
      expect(versioned_text.version_string).to eq("R0.0 — Dec 01, 2015 #{user.full_name}")
    end

    it "displays 'draft' when submitting_user is not defined" do
      versioned_text.updated_at = Time.local(2015, 12, 1, 10, 5, 0)
      expect(versioned_text.version_string).to eq("R0.0 — Dec 01, 2015 (draft)")
    end
  end
end
