require 'rails_helper'

describe ProcessManuscriptWorker do
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:manuscript_attachment) { FactoryGirl.build_stubbed(:manuscript_attachment, :with_pending_url) }
  subject(:worker) { described_class.new }

  describe "#perform" do
    before do
      # ProcessManuscriptWorker expects a paper with a creator and a
      # manuscript attachment, and ultimately sends a post to ihat. we need
      # to stub all that out, intercepting database update and http post
      # attempts
      allow(Paper).to receive(:find).with(paper.id).and_return paper
      allow(paper).to receive(:file).and_return manuscript_attachment
      allow(paper).to receive(:creator).and_return user
      allow(Attachment).to receive(:find).and_return manuscript_attachment
      allow(manuscript_attachment).to receive(:update_column)
      allow(manuscript_attachment).to receive(:paper).and_return paper
      allow(IhatJobRequest).to receive(:request_for_epub).and_return nil
    end

    it "does not retry" do
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end

    # A race condition can occur when downloading a file from S3 and then
    # processing it, where the final db commit doesn't complete before the
    # sidekiq worker tries to read from the database again. To simulate this
    # happening, we have a stubbed out paper and manuscript attachment, but at
    # this point manuscript_attachment.file.file is still nil. This starts the
    # worker, waits until the first polling attempt to retry, then updates
    # m_a.file.file to contain data.
    it "polls db again in missing file race condition" do
      thr = Thread.new do
        worker.perform manuscript_attachment.id
      end
      thr.abort_on_exception = true
      sleep 1
      manuscript_attachment[:file] = 'source.docx'
      thr.join
    end
  end
end
