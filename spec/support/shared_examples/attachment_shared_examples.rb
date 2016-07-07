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

RSpec.shared_examples_for 'attachment#download! knows when to keep and remove s3 files' do
  describe 'previously uploaded s3 file' do
    let(:url_1) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }
    let(:url_2) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

    before do
      subject.download!(url_1)
    end

    it 'is removed when it has never been snapshotted' do
      expect(subject).to receive(:remove_previously_stored_file)
      subject.download!(url_2)
    end

    it 'is not removed when it has been snapshotted' do
      snapshot = FactoryGirl.create(:snapshot, source: subject)
      expect(subject).to_not receive(:remove_previously_stored_file)
      url = 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg'
      subject.download!(url_2)
    end
  end
end

RSpec.shared_examples_for 'attachment#download! manages resource tokens' do
  describe 'managing resource tokens' do
    before do
      subject || fail('The calling example was expected to set up the subject, but it did not.')
      url || fail('The calling example was expected to set up a :url, but it did not.')
    end

    let(:resource_token) { subject.resource_token }

    it 'creates a resource token with URLs for each version of the file' do
      expect do
        subject.download!(url)
      end.to change { subject.resource_tokens.count }.by 1

      expect(resource_token.default_url).to eq(subject.file.store_path)
      subject.file.versions.keys.each do |version|
        resource_token_version_url = resource_token.version_urls[version.to_s]
        expect(resource_token_version_url).to eq \
          subject.file.versions[version.to_sym].store_path
      end
    end
  end
end
