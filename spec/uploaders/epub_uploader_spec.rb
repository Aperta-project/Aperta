require 'rails_helper'
require 'carrierwave/test/matchers'
require_relative '../../app/uploaders/epub_uploader'

describe EpubUploader do
  include CarrierWave::Test::Matchers
  let(:epub_fixture) {
    File.open(File.join(Rails.root, 'spec', 'fixtures', 'turtles.epub'), 'rb')
  }

  describe "#store_dir" do
    it "includes the paper id in the path" do
      paper = FactoryGirl.create(:paper)
      uploader = described_class.new(paper, :epub)
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/epub"
    end
  end
end
