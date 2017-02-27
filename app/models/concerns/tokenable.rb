# Module to use for models that should have a random token.
module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :set_access_token
  end

  private

  def set_access_token
    self.token = generate_token
  end

  def generate_token
    max_tries = 5
    tries = 0
    loop do
      token = SecureRandom.hex(10)
      tries += 1
      break token unless self.class.where(token: token).exists?
      raise "Cannot generate invitation token" if tries > max_tries
    end
  end
end
