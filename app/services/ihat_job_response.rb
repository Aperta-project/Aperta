# Models a response from ihat.
class IhatJobResponse
  attr_reader :outputs, :state, :metadata, :job_id

  def initialize(params = {})
    @state = params[:state].to_sym
    @outputs = params[:outputs]
    @metadata = params[:options][:metadata] || {}
    @job_id = params[:id]
  end

  def paper_id
    metadata[:paper_id]
  end

  def user_id
    metadata[:user_id]
  end

  def format_url(format)
    retval = outputs.detect { |o| o[:file_type] == format.to_s }
    retval && retval[:url]
  end

  [:pending, :processing, :completed, :errored, :archived, :skipped].each do |check_state|
    define_method("#{check_state}?") do
      state == check_state
    end
  end
end
