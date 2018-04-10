# Superclass for classes that look stuff up in NED
class NedConnection
  class ConnectionError < StandardError; end

  NED_ENABLED = TahiEnv.ned_enabled?
  BASE_URL = TahiEnv.ned_api_url
  APP_ID = TahiEnv.ned_cas_app_id
  APP_PASSWORD = TahiEnv.ned_cas_app_password
  RNF_MESSAGE = "Record not found"
  NED_SSL_VERIFY = TahiEnv.ned_ssl_verify?

  def self.enabled?
    NED_ENABLED
  end

  private

  def search(url, params = {})
    conn.get("#{BASE_URL}/#{url}", params)
  rescue Faraday::ClientError => e
    error_message = if e.response[:status] == 400
      RNF_MESSAGE
    else
      "Error connecting to #{BASE_URL}/#{url}"
    end
    # copied this over from the original file, im not sure this should be
    # the third arg to raise
    raise ConnectionError, error_message, e.response[:body]
  end

  def conn
    @conn ||= Faraday.new(ssl: { verify: NED_SSL_VERIFY }) do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(APP_ID, APP_PASSWORD)
    end
  end
end
