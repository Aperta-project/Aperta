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

    it 'can only update version numbers if it is a draft' do
      versioned_text = FactoryGirl.create(:versioned_text, major_version: nil, minor_version: nil)
      expect(versioned_text.valid?).to be(true)
      versioned_text.major_version = 1
      expect(versioned_text.valid?).to be(true)
      versioned_text.save!
      versioned_text.major_version = 2
      expect(versioned_text.valid?).to be(false)
    end
  end

  describe "#draft" do
    before do
      paper.versioned_texts.destroy_all
    end

    it "finds a draft version if one exists" do
      draft = paper.versioned_texts.create(major_version: nil, minor_version: nil)
      expect(paper.versioned_texts.draft.id).to be(draft.id)
    end

    it "creates a new draft version if there isn't one" do
      expect { paper.versioned_texts.draft }.to change { VersionedText.count }.by(1)
    end

    it "creates a VersionedText with no version number" do
      new_version = paper.versioned_texts.draft
      expect(new_version.major_version).to be_nil
      expect(new_version.minor_version).to be_nil
    end
  end

  describe "#be_minor_version!" do
    it "Creates a 0.0 version if there are no previous versions" do
      # This would happen for an initial submission
      draft = paper.draft
      draft.be_minor_version!
      expect(draft.major_version).to be(0)
      expect(draft.minor_version).to be(0)
    end

    it "Increments the minor version each time it is called" do
      paper.draft.be_minor_version!
      expect(paper.minor_version).to be(0)
      paper.draft.be_minor_version!
      expect(paper.minor_version).to be(1)
      paper.draft.be_minor_version!
      expect(paper.minor_version).to be(2)

      expect(paper.major_version).to be(0)
    end
  end

  describe "#be_major_version!" do
    it "Creates a 0.0 version if there are no previous versions" do
      # This would happen for an initial submission
      draft = paper.draft
      draft.be_major_version!
      expect(draft.major_version).to be(0)
      expect(draft.minor_version).to be(0)
    end

    it "increments the major version each time it is called" do
      paper.draft.be_major_version!
      expect(paper.major_version).to be(0)
      paper.draft.be_major_version!
      expect(paper.major_version).to be(1)
      paper.draft.be_major_version!
      expect(paper.major_version).to be(2)

      expect(paper.minor_version).to be(0)
    end
  end

  describe "#new_draft!" do
    it "Creates a new VersionedText" do
      versioned_text
      expect { versioned_text.new_draft! }.to change { VersionedText.count }.by(1)
    end

    it "has no version number" do
      draft = versioned_text.new_draft!
      expect(draft.major_version).to be_nil
      expect(draft.minor_version).to be_nil
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
end
