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

  describe "#filename" do
    subject(:attachment) { FactoryGirl.create(:attachment) }

    it "returns the proper filename" do
      attachment.update_attributes file: File.open('spec/fixtures/yeti.tiff')
      expect(attachment.filename).to eq "yeti.tiff"
    end
  end

  describe "validations" do
    subject(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_task) }
    it "is valid" do
      expect(attachment.valid?).to be(true)
    end

    it "requires an :owner" do
      attachment.owner = nil
      expect(attachment.valid?).to be(false)
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

  describe 'cancel_download' do
    subject(:attachment) { FactoryGirl.create(:attachment) }

    it 'destroys the attachment if status is STATUS_PROCESSING' do
      subject.status = Attachment::STATUS_PROCESSING
      subject.cancel_download
      expect(subject).to be_destroyed
    end

    it 'destroys the attachment if status is STATUS_ERROR' do
      subject.status = Attachment::STATUS_ERROR
      subject.cancel_download
      expect(subject).to be_destroyed
    end

    it 'does nothing if status is STATUS_DONE' do
      subject.status = Attachment::STATUS_DONE
      subject.cancel_download
      expect(subject).to_not be_destroyed
    end
  end

  describe 'download!' do
    # Many of the download examples are in attachment_shared_examples.rb
    # Look there for more
    subject(:attachment) { FactoryGirl.create(:attachment) }
    let(:url) { Faker::Internet.url('example.com') }

    before do
      allow(subject).to receive(:public_resource).and_return(true)
    end

    it 'stores the original uploaded url and error state on an exception' do
      ex = Exception.new("Download failed!")
      allow(subject.file).to receive(:download!).and_raise(ex)
      expect(subject).to receive(:on_download_failed).with(ex)
      Timecop.freeze(Time.now.utc + 10.days) do |later_time|
        subject.download!(url)
        expect(subject.status).to eq(Attachment::STATUS_ERROR)
        expect(subject.error_message).to eq(ex.message)
        expect(subject.error_backtrace).to be_present
        expect(subject.errored_at).to eq(later_time)
      end
    end
  end

  describe '#build_title' do
    it 'should return the title if set' do
      subject.title = Faker::Lorem.sentence
      expect(subject.send(:build_title)).to eq(subject.title)
    end

    it 'should return the filename if not set' do
      subject.title = nil
      filename = Faker::Lorem.word
      expect(subject.file).to receive(:filename).and_return(filename)
      expect(subject.send(:build_title)).to eq(filename)
    end
  end

  describe 'image?' do
    let(:path) { "spec/fixtures/bill_ted1.jpg" }
    subject(:attachment) do
      FactoryGirl.create(
        :attachment,
        file: File.open(Rails.root.join(path))
      )
    end

    context "a jpg file" do
      it 'returns true' do
        expect(subject.image?).to eq(true)
      end
    end

    context "is case insensitive with regard to the file extension" do
      let(:path) { "spec/fixtures/bill_ted2.JPG" }
      it 'returns true' do
        expect(subject.image?).to eq(true)
      end
    end

    context "a non-image file" do
      let(:path) { "spec/fixtures/about_turtles.docx" }
      it 'returns false' do
        expect(subject.image?).to eq(false)
      end
    end

    context "no file" do
      it 'returns false' do
        subject.update_columns(file: nil)
        expect(subject.reload.image?).to eq(false)
      end
    end
  end

  describe 'setting #paper' do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

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
    let(:url) { 'https://tahi-test.s3-us-west-1.amazonaws.com/uploads/journal/logo/1/thumbnail_yeti.jpg' }

    before do
      subject.public_resource = true
      subject.download!(url)
      FactoryGirl.create(:resource_token, owner: subject)
    end

    it 'does not destroy the resource token for the file being replaced' do
      current_resource_token = subject.resource_token
      subject.destroy
      expect(current_resource_token.reload).to be
    end
  end
end
