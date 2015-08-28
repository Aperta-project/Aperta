class NedCountries
  class ConnectionError < StandardError; end

  BASE_URL = ENV['NED_API_URL']
  APP_ID = ENV['NED_CAS_APP_ID']
  APP_PASSWORD = ENV['NED_CAS_APP_PASSWORD']

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
    ned_error = ConnectionError.new(e.response[:body])
    Bugsnag.notify(ned_error)
    raise ned_error
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
