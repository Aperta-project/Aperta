class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper, :epub_stream

  def perform(paper_id, epub_url)
    @paper = Paper.find(paper_id)
    @epub_stream = Faraday.get(epub_url).body
    sync!
  end

  def sync!
    paper.transaction do
      PaperAttributesExtractor.new(epub_stream).sync!(paper)
      FiguresExtractor.new(epub_stream).sync!(paper)
    end
  end
end
