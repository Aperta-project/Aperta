class IhatJobResponse
  attr_reader :outputs, :state, :raw_metadata

  def initialize(params={})
    @state = params[:state].to_sym
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

  [:pending, :processing, :completed, :errored, :archived, :skipped].each do |check_state|
    define_method("#{check_state}?") do
      state == check_state
    end
  end
end
