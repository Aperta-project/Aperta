# Prepare a manuscript for Ihat
class ProcessManuscriptWorker
  include Sidekiq::Worker

  # Retrying this could be confusing. If the user has fixed the problem by uploading
  # a new version, this would overwrite that when processed hours or days later.
  sidekiq_options :retry => false

  def perform(manuscript_attachment_id)
    manuscript_attachment = ManuscriptAttachment.find(manuscript_attachment_id)
    # Occasionally we don't have the file details from CarrierWave committed to
    # the database when this method kicks off. In that case, m_a.file.file will
    # be nil. When that happens, a new database lookup after 1 second typically
    # returns complete information. To be safe, we'll make five attempts, but I
    # have never seen this take more than 1.
    counter = 0
    while manuscript_attachment.file.file.nil? && counter < 5
      logger.info 'Attachment not ready yet, retrying in 1 second'
      counter += 1
      sleep 1
      manuscript_attachment = ManuscriptAttachment.find(manuscript_attachment_id)
    end
    set_file_type(manuscript_attachment)
    paper = manuscript_attachment.paper
    epub_stream = get_epub(paper)

    IhatJobRequest.request_for_epub(
      epub: epub_stream,
      source_url: manuscript_attachment.url,
      metadata: {
        paper_id: paper.id,
        user_id: manuscript_attachment.uploaded_by_id })
  end

  private

  def set_file_type(manuscript_attachment)
    manuscript_attachment.update_column(:file_type, manuscript_attachment.file.file.extension)
  end

  def get_epub(paper)
    converter = EpubConverter.new(
      paper,
      paper.creator)
    converter.epub_stream.string
  end
end
