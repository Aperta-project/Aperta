class NedProfileConnectionError < StandardError; end

class NedProfile

  BASE_URL = ENV['NED_API_URL']
  APP_ID = ENV['NED_CAS_APP_ID']
  APP_PASSWORD = ENV['NED_CAS_APP_PASSWORD']
  NED_DISABLE_SSL_VERIFICATION = ENV['NED_DISABLE_SSL_VERIFICATION'] == 'true'
  NED_SSL_VERIFY = !NED_DISABLE_SSL_VERIFICATION

  attr_accessor :cas_id

  def initialize(cas_id:)
    @cas_id = cas_id
  end

  def first_name
    profile["firstname"]
  end

  def last_name
    profile["lastname"]
  end

  def email
    credential["email"]
  end

  def display_name
    profile["displayname"]
  end

  def ned_id
    profile["nedid"]
  end

  def verified?
    credential["verified"] == 1
  end

  def to_h
    {
      first_name: first_name,
      last_name: last_name,
      email: email,
      display_name: display_name,
      ned_id: ned_id,
      cas_id: cas_id,
      verified: verified?
    }
  end


  private

  def conn
    @conn ||= Faraday.new(url: BASE_URL, ssl: { verify: NED_SSL_VERIFY }) do |faraday|
      faraday.response :json
      faraday.request  :url_encoded
      faraday.use      Faraday::Response::RaiseError
      faraday.adapter  Faraday.default_adapter
      faraday.basic_auth(APP_ID, APP_PASSWORD)
    end
  end

  def raw_attrs
    @raw_attrs ||= conn.get("/individuals/CAS/#{cas_id}").body
  rescue Faraday::ClientError => e
    ned_error = NedProfileConnectionError.new(e.response[:body])
    Bugsnag.notify(ned_error)
    raise ned_error
  end

  def credential
    @credential ||= raw_attrs["credentials"].detect do |cred|
      cred["isactive"] == 1
    end
  end

  def profile
    @profile ||= raw_attrs["individualprofiles"].detect do |profile|
      profile["isactive"] == true
    end
  end

end
