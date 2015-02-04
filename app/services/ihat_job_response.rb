class IhatJobResponse
  attr_reader :outputs, :state, :raw_metadata

  def initialize(params={})
    @state = params[:state]
    @outputs = params[:outputs]
    @raw_metadata = params[:metadata] || {}
  end

  def paper_id
    metadata[:paper_id]
  end

  def epub_url
    epub = outputs.detect { |o| o[:file_type] == "epub" }
    epub[:url]
  end

  def metadata
    @metadata ||= Verifier.new(raw_metadata).decrypt
  end

  def completed?
    state == "completed"
  end
end
