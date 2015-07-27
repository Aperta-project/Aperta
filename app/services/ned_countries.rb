class NedCountiesConnectionError < StandardError; end

class NedCountries

  BASE_URL = ENV['NED_API_URL']
  APP_ID = ENV['NED_CAS_APP_ID']
  APP_PASSWORD = ENV['NED_CAS_APP_PASSWORD']

  def countries
    if enabled
      typeclass = search("/typeclasses").body.detect { |tc|
        tc["description"] == "Country Types"
      }

      search("/typeclasses/#{typeclass['id']}/typevalues").body.map { |c|
        c["shortdescription"]
      }
    end
  end

  def enabled
    BASE_URL != ""
  end


  private

  def search(url)
    conn.get(url)
  rescue Faraday::ClientError => e
    ned_error = NedCountiesConnectionError.new(e.response[:body])
    Bugsnag.notify(ned_error)
    raise ned_error
  end

  def conn
    @conn ||= Faraday.new(url: BASE_URL) do |faraday|
      faraday.response :json
      faraday.request :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(APP_ID, APP_PASSWORD)
    end
  end

end
