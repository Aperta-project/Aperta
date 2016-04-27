require 'tahi_env/presence_validator'

class TahiEnv
  include ActiveModel::Validations

  def self.validates(env_var, *args)
    define_method(env_var) do
      ENV["#{env_var}"]
    end

    super
  end

  validates :FTP_HOST, presence: true
  validates :FTP_USER, presence: true
  validates :FTP_PASSWORD, presence: true
  validates :FTP_PORT, presence: true
  validates :FTP_DIRECTORY, presence: true
end
