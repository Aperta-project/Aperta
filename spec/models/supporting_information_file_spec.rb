require 'rails_helper'

describe SupportingInformationFile, redis: true do
  let(:paper) { FactoryGirl.create :paper }
  let(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/yeti.tiff')
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

end
