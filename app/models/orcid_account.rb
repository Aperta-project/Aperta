class OrcidAccount < ActiveRecord::Base
  include EventStream::Notifiable
  include UrlBuilder

  belongs_to :user
  attr_accessor :oauth_authorize_url

  class APIError < StandardError; end

  def update_orcid_profile!
    unless identifier && access_token
      raise OrcidAccount::APIError, 'Need an Orcid ID and access token before fetching profile'
    end

    api_profile_url = "https://#{TahiEnv.orcid_api_host}/" \
      + "v#{TahiEnv.orcid_api_version}/" \
      + "#{identifier}/orcid-profile"

    conn = Faraday.new(url: api_profile_url) do |faraday|
      faraday.response :json
      faraday.request  :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end

    response = conn.get do |req|
      req.headers['Accept'] = "application/json"
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Accept-Charset'] = "UTF-8"
    end

    names = response.body.dig('orcid-profile', 'orcid-bio', 'personal-details')

    name = [
      names.dig('given-names', 'value'),
      names.dig('family-name', 'value')
    ].compact.join(' ')

    update_attributes(
      name: name
    )

  rescue Faraday::ClientError => ex
    raise OrcidAccount::APIError, ex.to_s
  end

  def authenticated?
    !!(access_token && identifier)
  end

  def profile_url
    return unless identifier
    'http://' + TahiEnv.orcid_site_host + '/' + identifier
  end

  def access_token_valid
    return unless expires_at && access_token
    (expires_at > DateTime.now.utc) && access_token
  end

  def status
    return :unauthenticated unless access_token
    return :authenticated if access_token_valid
    :access_token_expired
  end

  def reset!
    exceptions = %w(id user_id created_at updated_at)
    attribute_names
      .reject { |attribute| exceptions.include?(attribute) }
      .each { |attribute| self[attribute] = nil }
    save!
  end

  def exchange_code_for_token(authorization_code)
    response_body = oauth_authorize(authorization_code)
    update_attributes(
      access_token: response_body['access_token'],
      refresh_token: response_body['access_token'],
      identifier: response_body['orcid'],
      expires_at: DateTime.now.utc + response_body['expires_in'].seconds,
      name: response_body['name'],
      scope: response_body['scope'],
    )
  end

  def oauth_authorize_url(
    orcid_site_host: TahiEnv.orcid_site_host,
    orcid_key: TahiEnv.orcid_key
  )
    "https://#{orcid_site_host}/oauth/authorize"\
    + "?client_id=#{orcid_key}"\
    + "&response_type=code"\
    + "&scope=/read-limited"\
    + "&redirect_uri=#{redirect_uri}"
  end

  def redirect_uri
    url_helpers.orcid_oauth_url
  end

  private

  def response_ensure_utf8(problem_string, headers)
    string = problem_string.dup
    return string if string.encoding == Encoding::UTF_8

    if string.encoding == Encoding::ASCII_8BIT &&
        headers[:content_type].try(:match, /UTF-8/)
      logger.warn "ORCID responded with charset=UTF-8 but sent ASCII-8BIT. Assuming ISO-8859-1 and converting to UTF-8."
      string.force_encoding("ISO-8859-1")
    end
    string.encode!(Encoding::UTF_8)
  rescue Encoding => ex
    logger.error "ORCID response failed to convert to UTF-8. Error: #{ex.message}"
    raise OrcidAccount::APIError, ex.to_s
  end

  def oauth_authorize(code)
    conn = Faraday.new(url: "https://#{TahiEnv.orcid_site_host}") do |faraday|
      faraday.request :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end
    params = {
      # client id and secret are Aperta's id and secret, NOT the end user's
      'client_id' => TahiEnv.orcid_key,
      'client_secret' => TahiEnv.orcid_secret,
      'grant_type' => 'authorization_code',
      'code' => code
    }
    response = conn.post("/oauth/token", params) do |request|
      request.headers['Accept'] = 'application/json'
      request.headers['Accept-Charset'] = "UTF-8"
    end

    response_body = JSON.parse response_ensure_utf8(response.body, response.headers)

    logger.info "ORCID OAuth authorizing. Sent code:#{code} Response:#{response.body}"
    # Inspecting body because ORCID sends HTTP 200 with errors as well.
    if response_body["errorDesc"] &&
        !response_body['errorDesc']['content'].empty?
      raise OrcidAccount::APIError, response_body['errorDesc']['content']
    end
    response_body

  rescue Faraday::ClientError => ex
    logger.error "ORCID API failed OAuth authorize step with message #{ex.message}"
    raise OrcidAccount::APIError, ex.to_s
  end
end
