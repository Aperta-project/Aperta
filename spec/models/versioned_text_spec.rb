# coding: utf-8
require 'rails_helper'

describe VersionedText do
  let(:paper) { FactoryGirl.create :paper }
  let(:user) { FactoryGirl.create :user }
  let(:versioned_text) { paper.latest_version }

  context 'validation' do
    subject(:versioned_text) { FactoryGirl.build(:versioned_text) }

    it 'is valid' do
      expect(versioned_text.valid?).to be(true)
    end

    it 'requires a paper' do
      versioned_text.paper = nil
      expect(versioned_text.valid?).to be(false)
    end

    it 'requires a major_version' do
      versioned_text.major_version = nil
      expect(versioned_text.valid?).to be(false)
    end

    it 'requires a minor_version' do
      versioned_text.minor_version = nil
      expect(versioned_text.valid?).to be(false)
    end
  end

  describe "#new_major_version!" do
    it "creates a new major version while retaining the old" do
      old_version = paper.latest_version
      paper.latest_version.new_major_version!
      expect(old_version.major_version).to eq(0)
      expect(old_version.minor_version).to eq(0)
      expect(VersionedText.where(paper: paper, major_version: 1, minor_version: 0).count).to eq(1)
    end

    it "resets the minor version when a new major version is created" do
      paper.latest_version.new_minor_version!
      paper.latest_version.new_major_version!
      expect([paper.latest_version.major_version, paper.latest_version.minor_version]).to eq([1, 0])
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
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      expect do
        FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
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

  describe 'updating original_text' do
    it 'should trigger an update of text' do
      expect(versioned_text).to receive(:insert_figures)
      versioned_text.update!(original_text: 'new original text')
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
