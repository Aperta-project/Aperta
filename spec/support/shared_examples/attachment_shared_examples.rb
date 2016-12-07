RSpec.shared_examples_for 'attachment#download! raises exception when it fails' do
  describe 'when download! fails' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'it raises the exception that caused it to fail' do
      allow(subject.file).to receive(:download!)
        .and_raise(Exception, "Download failed!")

      expect do
        subject.download!(url)
      end.to raise_error(Exception, "Download failed!")
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets the file_hash' do
  describe 'the file_hash' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to a SHA256 hexdigest of the file contents' do
      fixture_file = Rails.root.join('spec/fixtures', File.basename(url))
      unless File.exists?(fixture_file)
        fail <<-ERROR.strip_heredoc
          There is no local fixture file with a name matching the file in the
          provided url:

          url provided: #{url}
          looking for file: #{fixture_file}

          A fixture file needs to exist in order to determine that the file_hash
          is set correctly.
        ERROR
      end

      expect do
        subject.download!(url)
      end.to change {
        subject.file_hash
      }.to Digest::SHA256.hexdigest(IO.read(fixture_file))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! stores the file' do
  describe 'the file' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is downloaded from the given URL' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.file.path }.to match(File.basename(url))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! caches the s3 store_dir' do
  describe 'the s3 store_dir' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is cached' do
      expect do
        subject.download!(url)
        expect(subject.file_hash).to be
      end.to change { subject.reload.s3_dir }
      expect(subject.s3_dir).to eq \
        "uploads/paper/#{subject.paper_id}/attachment/#{subject.id}/#{subject.file_hash}"
    end

    it 'caches a new value when the file is replaced' do
      subject.download!(url)
      first_time_s3_dir = subject.s3_dir

      expect do
        new_url = 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg'
        subject.download!(new_url)
      end.to change { subject.reload.s3_dir }
      expect(subject.s3_dir).to_not eq first_time_s3_dir
      expect(subject.s3_dir).to eq \
        "uploads/paper/#{subject.paper_id}/attachment/#{subject.id}/#{subject.file_hash}"
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets title to file name' do
  describe 'sets the title' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to the file name' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.title }.to eq(File.basename(url))
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets the status' do
  describe 'setting the status' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    it 'is set to done' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.status }.to self.described_class::STATUS_DONE
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets the updated_at' do
  describe 'setting the updated_at' do
    before do
      subject || raise('The calling example was expected to set up the subject, but it did not.')
      url || raise('The calling example was expected to set up a :url, but it did not.')
    end

    it 'sets updated_at' do
      Timecop.freeze(Time.now.utc + 10.days) do |t|
        expect(subject.updated_at).not_to eq(t)
        expect(subject.file).to receive(:download!).with(url)
        allow(subject.file).to receive_message_chain('file.read').and_return('hello')
        expect do
          subject.download!(url)
        end.to change { subject.reload.updated_at }.to(within_db_precision.of(t))
      end
    end
  end
end

RSpec.shared_examples_for 'attachment#download! always keeps snapshotted files on s3' do
  describe 'previously uploaded s3 file' do
    let(:url_1) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }
    let(:url_2) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

    before do
      subject.download!(url_1)
    end

    context 'downloading a new file over an existing file' do
      it 'removes the existing file when it has never been snapshotted' do
        expect(subject).to receive(:remove_previously_stored_file)
        subject.download!(url_2)
      end

      it 'does not remove the existing file when it has been snapshotted' do
        snapshot = FactoryGirl.create(:snapshot, source: subject)
        expect(subject).to_not receive(:remove_previously_stored_file)
        subject.download!(url_2)
      end
    end

    context 'destroying the attachment' do
      it 'removes the existing file when it has never been snapshotted' do
        expect(subject).to receive(:remove_file!)
        subject.destroy!
      end

      it 'does not remove the existing file when it has been snapshotted' do
        snapshot = FactoryGirl.create(:snapshot, source: subject)
        expect(subject).to_not receive(:remove_file!)
        subject.destroy!
      end
    end
  end
end

RSpec.shared_examples_for 'attachment#download! always keeps files on s3, no matter what' do
  describe 'previously uploaded s3 file' do
    let(:url_1) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }
    let(:url_2) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

    before do
      subject.download!(url_1)
    end

    context 'downloading a new file over an existing file' do
      it 'does not remove the existing file' do
        expect(subject).to_not receive(:remove_previously_stored_file)
        subject.download!(url_2)
      end
    end

    context 'destroying the attachment' do
      it 'does not remove the existing file' do
        expect(subject).to_not receive(:remove_file!)
        subject.destroy!
      end
    end
  end
end

RSpec.shared_examples_for 'attachment#download! manages resource tokens' do
  describe 'managing resource tokens' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')

      # we don't want any resource tokens to exist for these shared examples,
      # but there's no need to bother the including test about this.
      subject.resource_tokens.delete_all

    end

    it 'creates a resource token with URLs for each version of the file' do
      expect do
        subject.download!(url)
      end.to change { subject.reload.resource_tokens.count }.by 1

      resource_token = subject.resource_token
      expect(resource_token.default_url).to eq(subject.file.store_path)
      subject.file.versions.keys.each do |version|
        resource_token_version_url = resource_token.version_urls[version.to_s]
        expect(resource_token_version_url).to eq \
          subject.file.versions[version.to_sym].store_path
      end
    end

    context 'and the attachment has a resource token, and is not snapshotted' do
      before do
        FactoryGirl.create(:resource_token, owner: subject)
      end

      it 'destroys the resource token for the file being replaced' do
        current_resource_token = subject.resource_token
        subject.download!(url)

        expect { current_resource_token.reload }.to \
          raise_error(ActiveRecord::RecordNotFound)

        # but it leaves the new resource token just made alone
        expect(subject.resource_token).to be
      end
    end

    context 'and the attachment has a resource token, and is snapshotted' do
      let(:url_2) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

      before do
        subject.download!(url)
        FactoryGirl.create(:resource_token, owner: subject)
        FactoryGirl.create(:snapshot, source: subject)
      end

      it 'does not destroy the resource token for the file being replaced' do
        current_resource_token = subject.resource_token
        subject.download!(url_2)
        expect(current_resource_token.reload).to be
      end
    end
  end
end

RSpec.shared_examples_for 'attachment#download! does not create resource tokens' do
  describe 'skip creating resource tokens' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')

      # we don't want any resource tokens to exist for these shared examples,
      # but there's no need to bother the including test about this.
      subject.resource_tokens.delete_all
    end

    it 'does not create resource tokens' do
      expect do
        subject.download!(url)
      end.to_not change { subject.resource_tokens.count }
    end
  end
end

RSpec.shared_examples_for 'attachment#download! sets the error fields' do
  context 'when the attachment#download! raises an exception' do
    before do
      subject || raise('The calling example was expected to set up the subject, but it did not.')
      url || raise('The calling example was expected to set up a :url, but it did not.')
    end

    it 'should set the status to errored if there is an error even if the attachment does not validate' do
      ex = Exception.new("Download failed!")
      allow(subject.file).to receive(:download!).and_raise(ex)

      expect(subject).to receive(:on_download_failed).with(ex)
      subject.download!('bogus url')

      # This happens in non-error cases too, but this is an easy place to test this.
      expect(subject.pending_url).to eq('bogus url')
      expect(subject.status).to eq(Attachment::STATUS_ERROR)
      expect(subject.error_message).to eq("Download failed!")
      expect(subject.error_backtrace).to be_present
      expect(subject.errored_at).to be_present
    end
  end
end
