require 'rails_helper'

describe PaperConverters::FigureProxy do
  let(:paper) { create :paper }
  let(:figure) { create :figure, paper: paper }
  let(:minor_version) { 0 }
  let(:major_version) { 0 }
  let(:detail_uri) { Faker::Internet.url }

  before :each do
    allow(paper).to receive(:minor_version).and_return(minor_version)
    allow(paper).to receive(:major_version).and_return(major_version)
    figure.resource_token.update! version_urls: { detail: detail_uri }
  end

  shared_examples_for 'a figure proxy' do
    describe 'href' do
      subject { figure_proxy.href }
      it { is_expected.to be_present }
    end

    describe 'title' do
      subject { figure_proxy.title }
      it { is_expected.to be_present }
    end
  end

  describe ".from_figure" do
    subject(:figure_proxy) { described_class.from_figure(figure) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a figure proxy'
  end

  describe ".from_snapshot" do
    let(:snapshot) do
      SnapshotService.new(paper).snapshot!(figure).first
    end
    subject(:figure_proxy) { described_class.from_snapshot(snapshot) }
    it { is_expected.to be_an_instance_of(described_class) }
    it_behaves_like 'a figure proxy'
  end
end
