class IHatJob

  attr_reader :epub_url, :state, :metadata
  
  def initialize(params={})
    @state = params[:state]
    @epub_url = params[:url]
    @metadata = params[:metadata] || {}
  end

  def paper_id
    metadata.fetch(:paper_id)
  end

  def converted?
    state == "converted"
  end
end
