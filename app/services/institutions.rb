require 'singleton'

class InstitutionsConnectionError < StandardError; end

class Institutions
  include Singleton

  USE_NED_INSTITUTIONS = TahiEnv.use_ned_institutions?
  BASE_URL = TahiEnv.ned_api_url
  APP_ID = TahiEnv.ned_cas_app_id
  APP_PASSWORD = TahiEnv.ned_cas_app_password
  NED_SSL_VERIFY = TahiEnv.ned_ssl_verify?

  def matching_institutions(query)
    if USE_NED_INSTITUTIONS
      search_ned query
    else
      search_predefined query
    end
  end

  private

  def predefined_institutions
    @institutions ||= YAML.load File.read Rails.root.join('config/institutions2.yml')
  end

  def search_predefined(query)
    predefined_institutions.select { |i| i['name'].downcase.match(query.downcase) }
  end

  def search_ned(query)
    conn.get('institutionsearch', substring: query).body
  rescue Faraday::ClientError => e
    ned_error = InstitutionsConnectionError.new(e.response[:body])
    Bugsnag.notify(ned_error)
    raise ned_error
  end

  def conn
    @conn ||= Faraday.new(url: BASE_URL, ssl: { verify: NED_SSL_VERIFY }) do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(APP_ID, APP_PASSWORD)
    end
  end
end
