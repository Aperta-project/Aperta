class NedCountries
  class ConnectionError < StandardError; end

  BASE_URL = TahiEnv.ned_api_url
  APP_ID = TahiEnv.ned_cas_app_id
  APP_PASSWORD = TahiEnv.ned_cas_app_password

  def self.enabled?
    BASE_URL.present?
  end

  def countries
    typeclass = search("typeclasses").body.detect { |tc|
      tc["description"] == "Country Types"
    }

    search("typeclasses/#{typeclass['id']}/typevalues").body.map { |c|
      c["shortdescription"]
    }
  end

  private

  def search(url)
    conn.get("#{BASE_URL}/#{url}")
  rescue Faraday::ClientError => e
    raise ConnectionError, "Error connecting to #{BASE_URL}/#{url}", e.response[:body]
  end

  def conn
    @conn ||= Faraday.new do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(APP_ID, APP_PASSWORD)
    end
  end
end
