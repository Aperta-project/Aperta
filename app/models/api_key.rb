class ApiKey < ActiveRecord::Base
  def self.generate!
    api_key = self.create!
    api_key.access_token
  end

  def initialize(attrs)
    super
    generate_access_token
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
