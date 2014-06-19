class DownloadManuscript < ActiveJob::Base
  queue_as :process_manuscripts

  def perform manuscript_id, url
    puts "Finding manuscript #{manuscript_id}"
    manuscript = Manuscript.find(manuscript_id)
    puts manuscript
    manuscript.source.download!(url)
    manuscript.status = "done"
    manuscript.save
    manuscript.paper.update OxgarageParser.new(open(manuscript.source.file.url)).to_hash
  end
end
