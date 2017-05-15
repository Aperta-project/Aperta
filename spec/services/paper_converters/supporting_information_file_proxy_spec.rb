require 'rails_helper'

describe PaperConverters::SupportingInformationFileProxy do
  let(:paper) { create :paper }
  let!(:supporting_information_file) { create :supporting_information_file, paper: paper }
  let!(:resource_token) { create :resource_token, owner: supporting_information_file }
  let(:minor_version) { 0 }
  let(:major_version) { 0 }
  let(:detail_uri) { Faker::Internet.url }
  let(:preview_uri) { Faker::Internet.url }

  before :each do
    allow(paper).to receive(:minor_version).and_return(minor_version)
    allow(paper).to receive(:major_version).and_return(major_version)
    supporting_information_file.resource_token.update! version_urls: { detail: detail_uri, preview: preview_uri }
  end

  shared_examples_for 'a supporting_information_file proxy' do
    describe 'href' do
      subject { supporting_information_file_proxy.href }
      it { is_expected.to be_present }
    end

    describe 'filename' do
      subject { supporting_information_file_proxy.filename }
      it { is_expected.to be_present }
    end

    describe 'id' do
      subject { supporting_information_file_proxy.id }
      it { is_expected.to be_present }
    end

    describe 'preview?' do
      subject { supporting_information_file_proxy.preview? }
      it { is_expected.to eq false }
    end
  end

  describe ".preview" do
    let(:supporting_information_file_proxy) { described_class.from_supporting_information_file(supporting_information_file) }
    subject { supporting_information_file_proxy.preview? }
    before do
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:exists?).and_return(exists_in_aws)
    end

    context "when CarrierWave says it exists" do
      let(:exists_in_aws) { true }

      it { is_expected.to eq true }
    end

    context "when CarrierWave says it does not exist" do
      let(:exists_in_aws) { false }

      it { is_expected.to eq false }
    end

    context "when preview_url is blank" do
      let(:exists_in_aws) { true }
      let(:preview_uri) { "" }

      it { is_expected.to eq false }
    end

    context "when preview_url is nil" do
      let(:exists_in_aws) { true }
      let(:preview_uri) { nil }

      it { is_expected.to eq false }
    end
  end

  describe ".from_supporting_information_file" do
    subject(:supporting_information_file_proxy) { described_class.from_supporting_information_file(supporting_information_file) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a supporting_information_file proxy'
  end

  describe ".from_snapshot" do
    let(:snapshot) do
      SnapshotService.new(paper).snapshot!(supporting_information_file).first
    end
    subject(:supporting_information_file_proxy) { described_class.from_snapshot(snapshot) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a supporting_information_file proxy'
  end

  describe ".from_versioned_text" do
    let(:versioned_text) { paper.versioned_texts.first }
    subject(:from_versioned_text) do
      described_class.from_versioned_text(versioned_text)
    end

    context "the VersionedText is the latest on the paper" do
      before do
        allow(versioned_text).to receive(:latest_version?).and_return(true)
        paper.reload
      end

      it "returns a list of SupportingInformationFileProxy objects" do
        expect(paper.supporting_information_files).to be_present
        expect(from_versioned_text.count).to eq paper.supporting_information_files.count
        from_versioned_text.each do |obj|
          expect(obj).to be_an_instance_of described_class
        end
      end

      it "creates SupportingInformationFileProxy objects from supporting_information_files" do
        expect(described_class).to receive(:from_supporting_information_file).once
        from_versioned_text
      end
    end

    context "the VersionedText is not the latest on the paper" do
      let!(:snapshot) do
        SnapshotService.new(paper).snapshot!(supporting_information_file).first
      end

      before do
        allow(versioned_text).to receive(:latest_version?).and_return(false)
        allow(versioned_text).to receive(:minor_version).and_return(minor_version)
        allow(versioned_text).to receive(:major_version).and_return(major_version)
        paper.reload
      end

      it "returns a list of SupportingInformationFileProxy objects" do
        expect(from_versioned_text.count).to eq 1
        from_versioned_text.each do |obj|
          expect(obj).to be_an_instance_of described_class
        end
      end

      it "creates supporting_information_fileProxy objects from snapshots" do
        expect(described_class).to receive(:from_snapshot).once
        from_versioned_text
      end
    end
  end
end
