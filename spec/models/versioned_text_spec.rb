# coding: utf-8
require 'rails_helper'

describe VersionedText do
  let(:paper) { FactoryGirl.create :paper }
  let(:user) { FactoryGirl.create :user }

  describe "#new_major_version!" do
    it "creates a new major version while retaining the old" do
      old_version = paper.latest_version
      paper.latest_version.new_major_version!
      expect(old_version.major_version).to eq(0)
      expect(old_version.minor_version).to eq(0)
      expect(VersionedText.where(paper: paper, major_version: 1, minor_version: 0).count).to eq(1)
    end

    it "sets the created_at timestamp" do
      paper.latest_version.update!(created_at: Time.zone.now - 10.days)
      paper.latest_version.new_major_version!
      expect(paper.latest_version.created_at.utc).to be_within(1.second).of Time.zone.now
    end
  end

  describe "#new_minor_version!" do
    it "creates a new minor version while retaining the old" do
      old_version = paper.latest_version
      paper.latest_version.new_minor_version!
      expect(old_version.major_version).to eq(0)
      expect(old_version.minor_version).to eq(0)
      expect(VersionedText.where(paper: paper, major_version: 0, minor_version: 1).count).to eq(1)
    end

    it "sets the created_at timestamp" do
      paper.latest_version.update!(created_at: Time.zone.now - 10.days)
      paper.latest_version.new_minor_version!
      expect(paper.latest_version.created_at.utc).to be_within(1.second).of Time.zone.now
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

  describe "#submitted?" do
    it 'should be true if submitting_user is set' do
      paper = FactoryGirl.create :paper
      expect(paper.latest_version.submitted?).to be(false)
      paper.latest_version.update!(submitting_user_id: 1)
      expect(paper.latest_version.submitted?).to be(true)
    end
  end

  describe '#version_string' do
    it "displays creator_name when submitting user is defined" do
      paper.latest_version.update!(submitting_user: user,
                                   updated_at: Time.local(2015, 12, 1, 10, 5, 0))
      expect(paper.version_string).to eq("R0.0 — Dec 01, 2015 #{user.full_name}")
    end

    it "displays 'draft' when submitting_user is not defined" do
      paper.latest_version.update(updated_at: Time.local(2015, 12, 1, 10, 5, 0))
      expect(paper.version_string).to eq("R0.0 — Dec 01, 2015 (draft)")
    end
  end

  it "should prevent writes on an old version" do
    old_version = paper.latest_version
    paper.latest_version.new_minor_version!
    expect { old_version.update!(text: "foo") }.to raise_exception(ActiveRecord::ReadOnlyRecord)
  end

  it "should prevent writes if paper is not editable" do
    paper.update!(editable: false)
    expect { paper.latest_version.update!(text: "foo") }.to raise_exception(ActiveRecord::ReadOnlyRecord)
  end

  it "should prevent writes if version is not a draft" do
    paper.latest_version.update!(submitting_user_id: 1)
    expect { paper.latest_version.update!(text: "foo") }.to raise_exception(ActiveRecord::ReadOnlyRecord)
  end
end
