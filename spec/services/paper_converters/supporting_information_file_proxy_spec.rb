require 'rails_helper'

describe PaperConverters::SupportingInformationFileProxy do
  let(:paper) { create :paper }
  let(:supporting_information_file) { create :supporting_information_file, paper: paper }
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

    describe 'has_preview?' do
      subject { supporting_information_file_proxy.has_preview? }
      it { is_expected.to eq true }
    end
  end

  describe ".from_supporting_information_file" do
    subject(:supporting_information_file_proxy) { described_class.from_supporting_information_file(supporting_information_file) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a supporting_information_file proxy'

    describe "href" do
      subject(:href) { supporting_information_file_proxy.href(is_proxied: true) }

      it "works" do
        href
      end
    end
  end

  describe ".from_snapshot" do
    let(:snapshot) do
      SnapshotService.new(paper).snapshot!(supporting_information_file).first
    end
    subject(:supporting_information_file_proxy) { described_class.from_snapshot(snapshot) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a supporting_information_file proxy'
  end
end
