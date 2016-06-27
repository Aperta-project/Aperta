require 'rails_helper'
require 'models/concerns/striking_image_shared_examples'

describe SupportingInformationFile, redis: true do
  let(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      FactoryGirl.create(
        :supporting_information_file,
        file: File.open('spec/fixtures/yeti.tiff'),
        status: described_class::STATUS_DONE
      )
    end
  end

  let(:file_src) { "/resource_proxy/supporting_information_files/#{file.token}" }

  it_behaves_like 'a striking image'

  describe '#download!', vcr: { cassette_name: 'supporting_info_file' } do
    subject(:si_file) { FactoryGirl.create(:supporting_information_file) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }

    it 'downloads the file at the given URL, caches the s3 store_dir' do
      si_file.download!(url)
      si_file.reload
      expect(si_file.file.path).to match(/bill_ted1\.jpg/)

      expect(si_file.file.store_dir).to be
      expect(si_file.s3_dir).to eq(si_file.file.store_dir)
    end

    it 'sets the title and status' do
      si_file.download!(url)
      si_file.reload
      expect(si_file.title).to eq('bill_ted1.jpg')
      expect(si_file.status).to eq(self.described_class::STATUS_DONE)
    end
  end

  describe '#filename' do
    it 'returns the proper filename' do
      expect(file.filename).to eq 'yeti.tiff'
    end
  end

  describe '#alt' do
    it 'returns a humanized alt name' do
      expect(file.alt).to eq 'Yeti'
    end
  end

  describe '#publishable' do
    it 'defaults to true' do
      expect(file.publishable).to eq true
    end
  end

  describe '#src' do
    it 'returns the file url' do
      expect(file.src).to eq(file_src)
    end
  end

  describe '#access_details' do
    it 'returns a hash with attachment src, filename, alt, and S3 URL' do
      expect(file.access_details).to eq(filename: 'yeti.tiff',
                                        alt: 'Yeti',
                                        src: file_src,
                                        id: file.id)
    end
  end

  describe '#token' do
    it 'is auto generated on create' do
      expect(file.token).to be_truthy
    end
  end
end
