class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper

  def perform(paper_id, epub_url)
    @paper = Paper.find(paper_id)
    sync!(epub_url)
  end

  def sync!(epub_url)
    epub_attributes = PaperAttributesExtractor.new(epub_url).to_hash
    paper.update!(body: epub_attributes[:body],
                  title: epub_attributes[:title],
                  abstract: epub_attributes[:abstract])
  end
end
