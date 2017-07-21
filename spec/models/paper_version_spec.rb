# coding: utf-8
require 'rails_helper'
require 'models/concerns/versioned_thing_shared_examples'

describe PaperVersion do
  let(:paper) { FactoryGirl.create :paper, :version_with_file_type }
  let(:user) { FactoryGirl.create :user }
  let(:paper_version) { paper.latest_version }

  it_behaves_like 'a thing with major and minor versions', :paper_version

  describe '#version_string' do
    it 'contains file_type' do
      expect(paper_version.version_string.match('DOCX').to_a.any?).to be(true)
    end

    it 'contains draft text' do
      expect(paper_version.version_string.match('draft').to_a.any?).to be(true)
    end

    it 'contains major and minor' do
      paper.draft.be_minor_version!
      expect(paper_version.version_string.match('0.0').to_a.any?).to be(true)
    end
  end

  describe '#version' do
    let(:new_paper_version) { FactoryGirl.create :paper_version }
    it 'returns semantic version if it is not a draft' do
      expect(new_paper_version.version).to eq('v1.0')
    end

    it 'returns latest draft if it is a draft' do
      expect(paper_version.version).to eq('latest draft')
    end
  end

  context 'validation' do
    context 'paper version is completed' do
      subject(:paper_version) { FactoryGirl.build(:paper_version) }

      it 'is valid' do
        expect(paper_version.valid?).to be(true)
      end

      it 'requires a paper' do
        paper_version.paper = nil
        expect(paper_version.valid?).to be(false)
      end
    end

    context 'paper version is a draft' do
      it 'can only update version numbers if it is a draft' do
        expect(paper_version).to be_draft
        expect(paper_version.valid?).to be(true)
        paper_version.major_version = 1
        expect(paper_version.valid?).to be(true)
        paper_version.save!
        paper_version.major_version = 2
        expect(paper_version.valid?).to be(false)
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

    it "has matching file and paper_version s3 directories" do
      paper.draft.be_minor_version!
      expect(paper.file.s3_dir).not_to be_nil
      expect(paper.file.s3_dir).to eq(paper_version.manuscript_s3_path)
    end

    it "has matching file and paper_version filenames" do
      paper.draft.be_minor_version!
      expect(paper.file[:file]).to eq(paper_version.manuscript_filename)
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

    it "has matching file and paper_version s3 directories" do
      paper.draft.be_major_version!
      expect(paper.file.s3_dir).not_to be_nil
      expect(paper.file.s3_dir).to eq(paper_version.manuscript_s3_path)
    end

    it "has matching file and paper_version filenames" do
      paper.draft.be_major_version!
      expect(paper.file[:file]).to eq(paper_version.manuscript_filename)
    end
  end

  describe "#new_draft!" do
    subject(:new_draft!) { paper_version.new_draft! }

    context "the paper_version is a draft" do
      let(:paper_version) { paper.draft }

      it "has no submitting user" do
        expect(paper_version.submitting_user).to be_nil
      end

      it "has matching file and paper_version s3 directories" do
        expect(paper.file.s3_dir).not_to be_nil
        expect(paper.file.s3_dir).to eq(paper_version.manuscript_s3_path)
      end

      it "has matching file and paper_version filenames" do
        expect(paper.file[:file]).to eq(paper_version.manuscript_filename)
      end

      it "fails" do
        expect { new_draft! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "the paper_version is completed" do
      let!(:paper_version) { paper.draft }

      before :each do
        paper_version.update! major_version: 0, minor_version: 0
      end

      it "Creates a new PaperVersion" do
        expect { new_draft! }.to change { PaperVersion.count }.by(1)
      end

      it "has no version number" do
        draft = new_draft!
        expect(draft.major_version).to be_nil
        expect(draft.minor_version).to be_nil
      end

      it "sets s3_dir and filename" do
        draft = new_draft!
        expect(draft.manuscript_s3_path).to be_present
        expect(draft.manuscript_filename).to be_present
      end
    end
  end

  describe "#create" do
    it "should not allow creating multiple versions with the same number" do
      FactoryGirl.create(:paper_version, paper: paper, major_version: 1, minor_version: 0)
      expect do
        FactoryGirl.create(:paper_version, paper: paper, major_version: 1, minor_version: 0)
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
        .and_return -> {}
    end

    it 'should trigger an update of text and figures' do
      expect(FigureInserter).to receive(:new)
        .with('new original text', [figure], {})
        .and_return -> {}
      paper_version.update!(original_text: 'new original text')
    end

    it 'uses the latest figures' do
      figure2 = FactoryGirl.create(:figure, owner: paper)
      expect(FigureInserter).to receive(:new)
        .with('new original text', [figure2], {})
        .and_return -> {}
      figure.destroy
      paper_version.update!(original_text: 'new original text')
    end
  end

  describe '#materialized_content' do
    let!(:resource_token) do
      create(
        :resource_token,
        version_urls: { 'detail' => 'test.jpg' }
      )
    end
    let(:paper_version) do
      create(:paper_version).tap { |vt| vt.update!(text: html) }
    end
    let(:expected_html) do
      <<-HTML.strip
        <h1>Hello</h1><img src="https://signed.jpg"><h3>World</h3>
      HTML
    end

    context 'a recent paper version record' do
      let(:html) do
        <<-HTML.strip
          <h1>Hello</h1><img src="/resource_proxy/12345/detail"><h3>World</h3>
        HTML
      end

      it 'should materialize text with corresponding figures' do
        allow(ResourceToken).to receive(:find_by_token).with('12345').and_return resource_token
        allow(Attachment).to receive(:authenticated_url_for_key).with(resource_token.version_urls['detail']).and_return 'https://signed.jpg'
        expect(paper_version.materialized_content).to eq(expected_html)
      end
    end

    # 'the embedded resource proxy urls changed at some point'
    context 'an old paper version record' do
      let(:html) do
        <<-HTML.strip
          <h1>Hello</h1><img src="/resource_proxy/figures/12345/detail"><h3>World</h3>
        HTML
      end

      it 'should materialize text with corresponding figures' do
        allow(ResourceToken).to receive(:find_by_token).with('12345').and_return resource_token
        allow(Attachment).to receive(:authenticated_url_for_key).with(resource_token.version_urls['detail']).and_return 'https://signed.jpg'
        expect(paper_version.materialized_content).to eq(expected_html)
      end
    end
  end
end
