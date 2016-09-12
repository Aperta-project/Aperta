require 'rails_helper'

describe Attachment do
  subject(:attachment) { FactoryGirl.build(:attachment) }

  describe '.authenticated_url_for_key' do
    subject(:authenticated_url) do
      described_class.authenticated_url_for_key('my/path.jpg')
    end

    it 'returns an authenticated S3 URL for the given url/path' do
      expected_url = 'https://tahi-test.s3-us-west-1.amazonaws.com/my/path.jpg'
      expect(authenticated_url).to match(/#{Regexp.escape(expected_url)}\?/)

      uri = URI.parse(authenticated_url)
      query_params = CGI.parse(uri.query)
      expect(query_params.keys).to contain_exactly(
        'X-Amz-Expires',
        'X-Amz-Date',
        'X-Amz-Algorithm',
        'X-Amz-Credential',
        'X-Amz-SignedHeaders',
        'X-Amz-Signature'
      )
    end
  end

  describe '#did_file_change?' do
    subject(:attachment) { FactoryGirl.create(:attachment) }

    it 'returns false when the file has not changed' do
      attachment.reload
      expect(attachment.did_file_change?).to eq false
    end

    context 'changes that are not yet saved' do
      context 'and the file_hash has changed' do
        it 'returns true' do
          attachment.file_hash = 'asdf1234'
          expect(attachment.did_file_change?).to eq true
        end
      end

      context 'and the file has changed, but not the file_hash' do
        it 'returns false' do
          attachment['file'] = 'foo.docx'
          attachment.save!
          expect(attachment.did_file_change?).to eq false
        end
      end

      context 'and the file has changed and there is no file hash' do
        it 'returns true' do
          attachment['file'] = 'foo.docx'
          attachment.file_hash = nil
          expect(attachment.did_file_change?).to eq true
        end
      end
    end

    context 'changes that were just saved' do
      context 'and the file_hash had changed' do
        it 'returns true' do
          attachment.update!(file_hash: 'asdf1234')
          expect(attachment.did_file_change?).to eq true
        end
      end

      context 'and the file had changed, but not the file_hash' do
        it 'returns false' do
          attachment['file'] = 'foo.docx'
          attachment.save!
          expect(attachment.did_file_change?).to eq false
        end
      end

      context 'and the file had changed and there is no file_hash' do
        it 'returns false' do
          attachment['file'] = 'foo.docx'
          attachment.file_hash = nil
          attachment.save!
          expect(attachment.did_file_change?).to eq true
        end
      end
    end
  end

  describe 'download!' do
    # Many of the download examples are in attachment_shared_examples.rb
    # Look there for more
    subject(:attachment) { FactoryGirl.create(:attachment) }

    it 'sets the error state on an exception' do
      allow(subject.file).to receive(:download!)
        .and_raise(Exception, "Download failed!")

      begin
        subject.download!('bogus url')
      rescue Exception
        expect(subject.status).to eq(Attachment::STATUS_ERROR)
      end
    end
  end

  describe 'setting #paper' do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:task, paper: paper) }

    it 'is set when assigning #owner and the owner is a Paper' do
      expect do
        attachment.owner = paper
      end.to change(attachment, :paper).to paper
    end

    it 'is set when assigning #owner and the owner responds to :paper' do
      expect do
        attachment.owner = task
      end.to change(attachment, :paper).to task.paper
    end

    it 'is set when the attachment is built thru an association whose owner has a paper' do
      attachment = task.attachments.build
      expect(attachment.paper).to eq(paper)
      expect(attachment.paper_id).to eq(paper.id)
    end

    it 'is set when the attachment is created thru an association whose owner has a paper' do
      attachment = task.attachments.create
      expect(attachment.paper).to eq(paper)
      expect(attachment.paper_id).to eq(paper.id)
    end
  end

  describe 'destroying', vcr: { cassette_name: 'attachment' } do
    subject(:attachment) { FactoryGirl.create(:attachment) }

    let(:url_1) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    context 'and the attachment has a resource token, and is not snapshotted' do
      before do
        FactoryGirl.create(:resource_token, owner: subject)
      end

      it 'destroys the resource token for the file being replaced' do
        current_resource_token = subject.resource_token
        subject.destroy
        expect { current_resource_token.reload }.to \
          raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'and the attachment has a resource token, and is snapshotted' do
      let(:url_2) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

      before do
        subject.public_resource = true
        subject.download!(url_1)
        FactoryGirl.create(:resource_token, owner: subject)
        FactoryGirl.create(:snapshot, source: subject)
      end

      it 'does not destroy the resource token for the file being replaced' do
        current_resource_token = subject.resource_token
        subject.destroy
        expect(current_resource_token.reload).to be
      end
    end
  end
end
