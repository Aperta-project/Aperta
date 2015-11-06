# Models a request for ihat.
class IhatJobRequest
  attr_reader :metadata

  def initialize(metadata = {})
    @metadata = metadata
  end

  def encrypted_payload
    Verifier.new(@metadata).encrypt(expiration_date: 1.month.from_now)
  end
end
