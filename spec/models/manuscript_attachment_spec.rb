require 'rails_helper'

describe ManuscriptAttachment do
  describe '#download!', vcr: { cassette_name: 'attachment' } do
    subject(:si_file) { FactoryGirl.create(:manuscript_attachment, :with_resource_token) }
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets title to file name'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! always keeps files on s3, no matter what'
    it_behaves_like 'attachment#download! does not create resource tokens'
  end
end
