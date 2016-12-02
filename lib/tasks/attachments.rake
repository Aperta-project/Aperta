namespace :attachments do
  desc 'Reprocess an attachment'
  task :reprocess, [:attachment_id] => [:environment] do |_, args|
    DownloadAttachmentWorker.reprocess(Attachment.find(args[:attachment_id]))
  end

  desc 'Batch reprocess attachments that are currently stuck in the `processing` state in groups of LIMIT (default 40)'
  task :batch_reprocess, [:limit] => [:environment] do |_, args|
    limit = args.fetch(:limit, 40)
    q = Attachment.processing.limit(limit)
    puts "Starting #{q.count} image processing jobs"
    q.each { |attachment| DownloadAttachmentWorker.reprocess(attachment) }
  end

  desc 'Batch reprocess attachments that errored in groups of LIMIT (default 40)'
  task :batch_reprocess_errored, [:limit] => [:environment] do |_, args|
    limit = args.fetch(:limit, 40)
    q = Attachment.error.where.not(pending_url: nil).limit(limit)
    puts "Starting #{q.count} image processing jobs"
    q.each { |attachment| DownloadAttachmentWorker.reprocess(attachment) }
  end
end
