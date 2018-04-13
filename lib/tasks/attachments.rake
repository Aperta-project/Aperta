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

namespace :attachments do
  desc 'Reprocess an attachment'
  task :reprocess, [:attachment_id] => [:environment] do |_, args|
    uploaded_by = (attachment.uploaded_by || attachment.paper.creator)
    DownloadAttachmentWorker.reprocess(Attachment.find(args[:attachment_id]), uploaded_by)
  end

  desc 'Batch reprocess attachments that are currently stuck in the `processing` state in groups of LIMIT (default 40)'
  task :batch_reprocess, [:limit] => [:environment] do |_, args|
    limit = args.fetch(:limit, 40)
    q = Attachment.processing.limit(limit)
    puts "Starting #{q.count} image processing jobs"
    q.each do |attachment|
      uploaded_by = (attachment.uploaded_by || attachment.paper.creator)
      DownloadAttachmentWorker.reprocess(attachment, uploaded_by)
    end
  end

  desc 'Batch reprocess attachments that errored in groups of LIMIT (default 40)'
  task :batch_reprocess_errored, [:limit] => [:environment] do |_, args|
    limit = args.fetch(:limit, 40)
    q = Attachment.error.where.not(pending_url: nil).limit(limit)
    puts "Starting #{q.count} image processing jobs"
    q.each do |attachment|
      uploaded_by = (attachment.uploaded_by || attachment.paper.creator)
      DownloadAttachmentWorker.reprocess(attachment, uploaded_by)
    end
  end
end
