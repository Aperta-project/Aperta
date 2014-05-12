require 'spec_helper'

describe SourceUploader do
  let(:paper)       { FactoryGirl.create(:paper) }
  let(:manuscript)  { FactoryGirl.create(:manuscript, paper: paper) }
  let(:uploader)    { manuscript.source }

  describe "#store_dir" do
    it "has the correct path" do
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/manuscript"
    end
  end

  describe "#filename" do
    it "is called 'source.docx'" do
      expect(uploader.filename).to eq "source.docx"
    end
  end
end
