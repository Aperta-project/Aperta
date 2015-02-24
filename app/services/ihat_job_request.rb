class IhatJobRequest
  attr_reader :paper

  def initialize(paper:)
    @paper = paper
  end

  def queue(file_url:, callback_url:)
    manuscript.transaction do
      manuscript.update_attribute(:status, "processing")
      DownloadManuscriptWorker.perform_async(manuscript.id, file_url, callback_url, encrypted_payload)
    end
  end

  private

  def manuscript
    paper.manuscript.presence || paper.build_manuscript
  end

  def encrypted_payload
    payload = { paper_id: paper.id }
    Verifier.new(payload).encrypt(expiration_date: 1.month.from_now)
  end
end
