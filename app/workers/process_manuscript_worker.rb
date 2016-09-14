# Prepare a manuscript for Ihat
class ProcessManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_attachment_id)
    manuscript_attachment = ManuscriptAttachment.find(manuscript_attachment_id)
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

  def get_epub(paper)
    converter = EpubConverter.new(
      paper,
      paper.creator,
      include_source: true,
      include_cover_image: false)
    converter.epub_stream.string
  end
end
