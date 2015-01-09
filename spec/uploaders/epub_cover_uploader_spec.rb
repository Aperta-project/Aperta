require 'rails_helper'

describe EpubCoverUploader do
  describe "#store_dir" do
    it "includes the paper id in the path" do
      journal = FactoryGirl.create :journal
      uploader = EpubCoverUploader.new(journal, :epub_cover)
      expect(uploader.store_dir).to eq "uploads/journal/epub_cover/#{journal.id}"
    end
  end
end
