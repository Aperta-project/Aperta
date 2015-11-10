# Models a request for ihat.
class IhatJobRequest
  attr_reader :file

  def initialize(file:, recipe_name: 'docx_to_html',
                 callback_url: nil, metadata: {})
    @file = file
    @recipe_name = recipe_name
    @callback_url = callback_url
    @metadata = metadata
  end

  def make_options
    { recipe_name: @recipe_name }.tap do |options|
      options[:callback_url] = @callback_url if @callback_url
      options[:metadata] = encrypted_payload if @metadata
    end
  end

  private

  def encrypted_payload
    Verifier.new(@metadata).encrypt(expiration_date: 1.month.from_now)
  end
end
