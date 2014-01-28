require 'spec_helper'

describe LogoUploader do
  describe "#store_dir" do
    it "includes the paper id in the path" do
      journal = Journal.create!
      uploader = LogoUploader.new(journal, :logo)
      expect(uploader.store_dir).to eq "uploads/journal/logo/#{journal.id}"
    end
  end
end
