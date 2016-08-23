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
