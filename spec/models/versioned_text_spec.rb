# coding: utf-8
require 'rails_helper'
require 'models/concerns/versioned_thing_shared_examples'

describe VersionedText do
  let(:paper) { FactoryGirl.create :paper }
  let(:user) { FactoryGirl.create :user }
  let(:versioned_text) { paper.latest_version }

  it_behaves_like 'a thing with major and minor versions', :versioned_text

  context 'validation' do
    context 'versioned text is completed' do
      subject(:versioned_text) { FactoryGirl.build(:versioned_text) }

      it 'is valid' do
        expect(versioned_text.valid?).to be(true)
      end

      it 'requires a paper' do
        versioned_text.paper = nil
        expect(versioned_text.valid?).to be(false)
      end
    end

    context 'versioned text is a draft' do
      it 'can only update version numbers if it is a draft' do
        expect(versioned_text).to be_draft
        expect(versioned_text.valid?).to be(true)
        versioned_text.major_version = 1
        expect(versioned_text.valid?).to be(true)
        versioned_text.save!
        versioned_text.major_version = 2
        expect(versioned_text.valid?).to be(false)
      end
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
      paper.new_draft!
      paper.draft.be_minor_version!
      expect(paper.minor_version).to be(1)
      paper.new_draft!
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
      paper.new_draft!
      paper.draft.be_major_version!
      expect(paper.major_version).to be(1)
      paper.new_draft!
      paper.draft.be_major_version!
      expect(paper.major_version).to be(2)

      expect(paper.minor_version).to be(0)
    end
  end

  describe "#new_draft!" do
    subject(:new_draft!) { versioned_text.new_draft! }

    context "the versioned_text is a draft" do
      let(:versioned_text) { paper.draft }

      it "fails" do
        expect { new_draft! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "the versioned_text is completed" do
      let!(:versioned_text) { paper.draft }

      before :each do
        versioned_text.update! major_version: 0, minor_version: 0
      end

      it "Creates a new VersionedText" do
        expect { new_draft! }.to change { VersionedText.count }.by(1)
      end

      it "has no version number" do
        draft = new_draft!
        expect(draft.major_version).to be_nil
        expect(draft.minor_version).to be_nil
      end
    end
  end

  describe "#create" do
    it "should not allow creating multiple versions with the same number" do
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      expect do
        FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      end.to raise_exception(ActiveRecord::RecordInvalid)
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
    let!(:figure) { FactoryGirl.create(:figure, owner: paper) }

    before do
      allow(FigureInserter).to receive(:new)
        .and_return -> { }
    end

    it 'should trigger an update of text and figures' do
      expect(FigureInserter).to receive(:new)
        .with('new original text', [figure], {})
        .and_return -> { }
      versioned_text.update!(original_text: 'new original text')
    end

    it 'uses the latest figures' do
      figure2 = FactoryGirl.create(:figure, owner: paper)
      expect(FigureInserter).to receive(:new)
        .with('new original text', [figure2], {})
        .and_return -> { }
      figure.destroy
      versioned_text.update!(original_text: 'new original text')
    end
  end
end
