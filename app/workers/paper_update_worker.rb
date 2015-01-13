class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper, :epub_json

  def perform(paper_id, epub_url)
    @paper = Paper.find(paper_id)
    @epub_json = extract_json(epub_url)
    sync!
  end

  def sync!
    paper.update!(body: epub_attributes[:body],
                  title: epub_attributes[:title])
  end

  private

  def epub_attributes
    @epub_attributes ||= TahiEpub::JSONParser.parse(epub_json)
  end

  def extract_json(url)
    file = Faraday.get(url).body
    TahiEpub::Zip.extract(stream: file, filename: 'converted.json')
  end
end
