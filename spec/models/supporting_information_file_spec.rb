require 'rails_helper'
require 'models/concerns/striking_image_shared_examples'

describe SupportingInformationFile, redis: true do
  let(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      FactoryGirl.create(
        :supporting_information_file,
        :with_resource_token,
        file: File.open('spec/fixtures/yeti.tiff'),
        status: described_class::STATUS_DONE
      )
    end
  end

  let(:file_src) { "/resource_proxy/#{file.token}" }

  it_behaves_like 'a striking image'

  describe '#download!', vcr: { cassette_name: 'attachment' } do
    subject(:si_file) { FactoryGirl.create(:supporting_information_file, :with_resource_token) }
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets title to file name'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! knows when to keep and remove s3 files'
    it_behaves_like 'attachment#download! manages resource tokens'
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
      expect(file.access_details).to eq(
        filename: 'yeti.tiff',
        alt: 'Yeti',
        src: file_src,
        id: file.id
      )
    end
  end
end
