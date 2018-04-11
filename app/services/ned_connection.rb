# Superclass for classes that look stuff up in NED
class NedConnection
  class ConnectionError < StandardError; end

  RNF_MESSAGE = "Record not found"

  def self.enabled?
    TahiEnv.ned_enabled?
  end

  private

  def search(url, params = {})
    conn.get("#{TahiEnv.ned_api_url}/#{url}", params)
  rescue Faraday::ClientError => e
    error_message = if e.response[:status] == 400
      RNF_MESSAGE
    else
      "Error connecting to #{TahiEnv.ned_api_url}/#{url}"
    end
    # copied this over from the original file, im not sure this should be
    # the third arg to raise
    raise ConnectionError, error_message, e.response[:body]
  end

  def conn
    @conn ||= Faraday.new(ssl: { verify: TahiEnv.ned_ssl_verify? }) do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(TahiEnv.ned_cas_app_id, TahiEnv.ned_cas_app_password)
    end
  end
end
