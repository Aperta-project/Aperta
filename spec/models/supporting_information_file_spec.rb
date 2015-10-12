require 'rails_helper'

describe SupportingInformationFile, redis: true do
  let(:paper) { FactoryGirl.create :paper }
  let(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/yeti.tiff')
    end
  end

  let(:docx) do
    with_aws_cassette 'supporting_info_files_controller' do
      paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/about_turtles.docx')
    end
  end

  describe "#filename" do
    it "returns the proper filename" do
      expect(file.filename).to eq "yeti.tiff"
    end
  end

  describe "#alt" do
    it "returns a humanized alt name" do
      expect(file.alt).to eq "Yeti"
    end
  end

  describe "#publishable" do
    it "defaults to true" do
      expect(file.publishable).to eq true
    end
  end

  describe "#src" do
    it "returns the file url" do
      expect(file.src).to match /yeti\.tiff/
    end
  end

  describe "#access_details" do
    it "returns a hash with attachment src, filename, alt, and S3 URL" do
      expect(file.access_details).to eq(filename: 'yeti.tiff',
                                        alt: 'Yeti',
                                        src: file.attachment.url,
                                        id: file.id)
    end
  end

  describe "supports non-image supporting information" do
    it "can be downloaded" do
      expect(docx.access_details).to eq(filename: 'about_turtles.docx',
                                        alt: 'About turtles',
                                        src: docx.attachment.url,
                                        id: docx.id)
    end

    it "does not have a preview url" do
      expect(docx.preview_src).to eq(nil)
    end


  end
end
