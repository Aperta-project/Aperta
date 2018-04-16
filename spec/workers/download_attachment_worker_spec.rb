# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe DownloadAttachmentWorker, redis: true do
  let(:worker) { described_class.new }

  describe 'downloading attachments(s)' do
    let(:attachment) { FactoryGirl.build_stubbed(:attachment) }
    let(:url) { "http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg" }
    let(:user) { FactoryGirl.build_stubbed(:user) }

    describe ".download_attachment" do
      it "sets the attachment to processing and queues up sidekiq job" do
        expect(attachment).to receive(:update_attribute)
          .with(:status, Attachment::STATUS_PROCESSING)
        described_class.download_attachment(attachment, url, user)
        expect(DownloadAttachmentWorker).to have_queued_job(attachment.id, url, user.id)
      end
    end

    describe ".reprocess" do
      it "short circuits if `pending_url` is nil" do
        expect(attachment).to receive(:pending_url).and_return(nil)
        described_class.reprocess(attachment, user)
        expect(DownloadAttachmentWorker).to have_empty_queue
      end

      it "creates a download attachment process" do
        allow(attachment).to receive(:pending_url).and_return(url)
        expect(attachment).to receive(:update_attribute).with(:status, Attachment::STATUS_PROCESSING)
        described_class.reprocess(attachment, user)
        expect(DownloadAttachmentWorker).to have_queued_job(attachment.id, url, user.id)
      end
    end

    context "with a user and attachment" do
      before do
        allow(User).to receive(:find)
          .with(user.id).and_return user
        allow(Attachment).to receive(:find)
          .with(attachment.id).and_return attachment
      end

      it "downloads the attachment" do
        expect(attachment).to receive(:download!)
          .with(url, uploaded_by: user)
        worker.perform(attachment.id, url, user.id)
      end
    end

    it "rescues ActiveRecord::RecordNotFound" do
      expect { worker.perform(2, "fake url", 50) }.to_not raise_error
    end

    it "does not retry" do
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end
  end
end
