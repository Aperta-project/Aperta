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
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! always keeps snapshotted files on s3'
    it_behaves_like 'attachment#download! manages resource tokens'
    it_behaves_like 'attachment#download! sets the updated_at'
    it_behaves_like 'attachment#download! sets the error fields'
    it_behaves_like 'attachment#download! when the attachment is invalid'
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

  describe '#build_title' do
    it 'returns the title' do
      file.title = Faker::Lorem.sentence
      expect(file.send(:build_title_html)).to eq(file.title)
    end

    it 'returns nil if the title is nil' do
      expect(file.title).to be_nil
      expect(file.send(:build_title_html)).to be_nil
    end
  end
end
