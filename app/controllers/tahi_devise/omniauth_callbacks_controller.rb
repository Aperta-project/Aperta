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

module TahiDevise
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include DisableSubmissions
    class SSOAuthError < StandardError; end

    def cas
      ned = auth[:extra]
      downcased_email = ned[:emailAddress].strip.downcase
      user =
        if credential.present?
          credential.user
        else
          User.find_or_create_by(email: downcased_email).tap do |user|
            user.credentials.build(uid: auth[:uid], provider: :cas)
          end
        end
      # update user profile with latest attributes from NED
      user.first_name = ned[:firstName]
      user.last_name = ned[:lastName]
      user.email = downcased_email
      user.username = ned[:displayName]
      user.ned_id = ned[:nedId]
      user.auto_generate_password
      user.save!
      flash[:alert] = sign_in_alert
      sign_in_and_redirect(user, event: :authentication)
    end

    # We are using the "Orcid Member API", which gives us access to privilaged information.
    # It let's us query for detailed profile information. Unfortunately, Orcid's default is
    # that email addresses are private. The user can change their email address to be public,
    # and we can get it back, but let's face it, nobody's going to do that. Even though we
    # are reading "limited access data", the field is private and this prevents Orcid
    # from sending us the email address.
    #
    # So, redirect to a page that prefills any orcid profile information and collects email.
    #
    def orcid
      Rails.logger.info auth.inspect

      person_object = auth[:info]
      oauth_object = auth[:extra]
      oauth_params = oauth_object[:params]
      orcid_account = OrcidAccount.find_or_initialize_by(identifier: auth[:uid]) do |account|
        account.access_token = oauth_object[:access_token]
        account.refresh_token = oauth_object[:refresh_token]
        account.expires_at = DateTime.now.utc + oauth_object[:expires_in].seconds
        account.name = oauth_params['name']
        account.scope = oauth_params['scope']
      end

      # if the account is new and doesnt have a user, fetch details and enforce email presence
      unless user = (credential.try(:user) || orcid_account.user)
        email_objects = person_object.dig('emails', 'email')
        raise SSOAuthError, 'Please allow your emails to be visible to trusted partners. (link to instructions)' if email_objects.empty?
        email_object = email_objects.detect { |obj| obj['primary'] && obj['verified'] }
        raise SSOAuthError, 'Please use a verified email address. (link to instructions)' if email_object.nil?
        user = User.find_or_create_by!(email: email_object['email']) do |u|
          u.first_name = person_object.dig('name', 'given-name', 'value')
          u.last_name = person_object.dig('name', 'family-name', 'value') # optional in orcid
          u.auto_generate_password
          u.auto_generate_username
          u.credentials.build(uid: auth[:uid], provider: :orcid)
        end
        orcid_account.update!(user: user)
      end

      sign_in_and_redirect(orcid_account.user)
    end

    private

    def credential
      @credential ||= Credential.find_by(auth.slice(:uid, :provider))
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end

    def orcid_client
      @client ||= OAuth2::Client.new(TahiEnv.orcid_key, TahiEnv.orcid_secret, site: "https://#{TahiEnv.orcid_site_host}")
    end

    def headers
      { 'Accept': 'application/json', 'Accept-Charset': 'UTF-8' }
    end
  end
end
