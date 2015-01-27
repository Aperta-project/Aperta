class IhatJobResponse
  attr_reader :epub_url, :state, :raw_metadata

  def initialize(params={})
    @state = params[:state]
    @epub_url = params[:epub_url]
    @raw_metadata = params[:metadata] || {}
  end

  def paper_id
    metadata[:paper_id]
  end

  def metadata
    @metadata ||= Verifier.new(raw_metadata).decrypt
  end

  def completed?
    state == "completed"
  end
end
