# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe PaperConverters::FigureProxy do
  let(:paper) { create :paper }
  let(:figure) { create :figure, owner: paper }
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

    describe 'rank' do
      subject { figure_proxy.rank }
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

      it "returns a list of FigureProxy objects" do
        expect(paper.figures).to be_present
        expect(from_versioned_text.count).to eq paper.figures.count
        from_versioned_text.each do |obj|
          expect(obj).to be_an_instance_of described_class
        end
      end

      it "creates FigureProxy objects from figures" do
        expect(described_class).to receive(:from_figure).once
        from_versioned_text
      end
    end

    context "the VersionedText is not the latest on the paper" do
      let!(:snapshot) do
        SnapshotService.new(paper).snapshot!(figure).first
      end

      before do
        allow(versioned_text).to receive(:latest_version?).and_return(false)
        allow(versioned_text).to receive(:minor_version).and_return(minor_version)
        allow(versioned_text).to receive(:major_version).and_return(major_version)
        paper.reload
      end

      it "returns a list of FigureProxy objects" do
        expect(from_versioned_text.count).to eq 1
        from_versioned_text.each do |obj|
          expect(obj).to be_an_instance_of described_class
        end
      end

      it "creates FigureProxy objects from snapshots" do
        expect(described_class).to receive(:from_snapshot).once
        from_versioned_text
      end
    end
  end
end
