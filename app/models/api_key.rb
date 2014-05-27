class ApiKey < ActiveRecord::Base
  before_create :generate_access_token

  def self.generate_access_token
    api_key = self.create!
    api_key.access_token
  end

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end

