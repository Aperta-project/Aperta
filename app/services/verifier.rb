class MessageExpired < StandardError; end
class InvalidPayload < StandardError; end

class Verifier
  attr_accessor :data

  EXPIRATION_DATE_KEY = "_verifier_expiration_date".freeze

  def initialize(data = {})
    @data = data.dup
  end

  def encrypt(expiration_date: nil)
    add_expiration_date(expiration_date) if expiration_date.present?
    verifier.generate(data)
  end

  def decrypt
    decrypted.tap do
      validate_expiration! if expiration_date
    end
  end

  def expiration_date
    @expiration_date ||= decrypted.delete(EXPIRATION_DATE_KEY)
  end

  private

  def verifier
    @verifier ||= Rails.application.message_verifier(:ihat_verifier)
  end

  def decrypted
    @decrypted ||= verifier.verify(data)
  end

  def expired?
    expiration_date && Time.now > expiration_date
  end

  def add_expiration_date(expiration_date)
    data[EXPIRATION_DATE_KEY] = expiration_date
  rescue IndexError
    raise InvalidPayload, "Data to be encrypted with expiration date must be a hash"
  end

  def validate_expiration!
    raise MessageExpired if expired?
  end
end
