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

    response = RestClient.get(api_profile_url,
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => "application/orcid+xml")

    update_attributes(
      profile_xml: response_ensure_utf8(response.body),
      profile_xml_updated_at: DateTime.now.utc
    )
  rescue RestClient::ExceptionWithResponse => ex
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
    response = oauth_authorize(authorization_code)
    update_attributes(
      access_token: response['access_token'],
      refresh_token: response['access_token'],
      identifier: response['orcid'],
      expires_at: DateTime.now.utc + response['expires_in'].seconds,
      name: response['name'],
      scope: response['scope'],
      authorization_code_response: response
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

  def response_ensure_utf8(response)
    body = response.body.dup
    return body if body.encoding == Encoding::UTF_8

    if body.encoding == Encoding::ASCII_8BIT &&
        response.headers[:content_type].try(:match, /UTF-8/)
      logger.warn "ORCID responded with content_type=UTF-8 but sent ASCII-8BIT. Assuming ISO-8859-1 and converting to UTF-8."
      body.force_encoding("ISO-8859-1")
    end
    body.encode!(Encoding::UTF_8)
  rescue Encoding => ex
    logger.error "ORCID response failed to convert to UTF-8. Body:#{body}. Error: #{ex.message}"
    raise OrcidAccount::APIError, ex.to_s
  end

  def oauth_authorize(code)
    # client id and secret are Aperta's id and secret, NOT the end user's
    raw_response = RestClient.post(
      "https://#{TahiEnv.orcid_site_host}/oauth/token", {
        'client_id' => TahiEnv.orcid_key,
        'client_secret' => TahiEnv.orcid_secret,
        'grant_type' => 'authorization_code',
        'code' => code
      }, 'Accept' => 'application/json'
    )

    logger.info "ORCID OAuth authorizing. Sent code:#{code} Response:#{raw_response}"

    response = JSON.parse response_ensure_utf8 raw_response

    if response["errorDesc"] &&
        !response['errorDesc']['content'].empty?
      raise OrcidAccount::APIError, response['errorDesc']['content']
    end
    response
  rescue RestClient::ExceptionWithResponse => ex
    logger.error "ORCID API failed OAuth authorize step with message #{ex.message}"
    raise OrcidAccount::APIError, ex.to_s
  end
end
