# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class OrcidAccount < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable
  include UrlBuilder

  belongs_to :user
  attr_accessor :oauth_authorize_url

  class APIError < StandardError; end

  def update_orcid_profile!
    unless identifier && access_token
      raise OrcidAccount::APIError, 'Need an Orcid ID and access token before fetching profile'
    end

    client.site = 'https://' + TahiEnv.orcid_api_host # actually use api endpoint for getting user data
    token = OAuth2::AccessToken.new(client, access_token)

    # TODO: Handle expired access token case
    response_hash = token.get("/v2.0/#{identifier}/personal-details", headers: headers).parsed
    name = [
      response_hash.dig('name', 'given-names', 'value'),
      response_hash.dig('name', 'family-name', 'value')
    ].compact.join(' ')

    update_attributes(name: name)

  rescue OAuth2::Error => ex
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
    oauth_response = client.auth_code.get_token(authorization_code, headers: headers)
    raise OrcidAccount::APIError, 'Access token missing' unless oauth_response.token # not great if we dont get an access token back
    update_attributes(
      access_token: oauth_response.token,
      refresh_token: oauth_response.refresh_token,
      identifier: oauth_response.params['orcid'],
      expires_at: DateTime.now.utc + oauth_response.expires_in.seconds,
      name: oauth_response.params['name'],
      scope: oauth_response.params['scope']
    )
  rescue OAuth2::Error => ex
    logger.error "ORCID API failed OAuth authorize step with message #{ex.message}"
    raise OrcidAccount::APIError, ex.to_s
  end

  def oauth_authorize_url
    client.auth_code.authorize_url(redirect_uri: redirect_uri, scope: '/read-limited')
  end

  def redirect_uri
    url_helpers.orcid_oauth_url
  end

  private

  def client
    @client ||= OAuth2::Client.new(TahiEnv.orcid_key, TahiEnv.orcid_secret, site: "https://#{TahiEnv.orcid_site_host}")
  end

  def headers
    { 'Accept': 'application/json', 'Accept-Charset': 'UTF-8' }
  end
end
