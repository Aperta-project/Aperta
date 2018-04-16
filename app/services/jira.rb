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

# Service class to handle communication with JIRA
class Jira
  class << self
    def create_issue(user_id, feedback_params)
      user = User.find(user_id)
      feedback_params.deep_symbolize_keys!
      session_token = authenticate!
      payload = build_payload(user, feedback_params)

      Rails.logger.info "creating JIRA issue with params: #{payload}"
      response = faraday_connection.post do |req|
        req.url TahiEnv.jira_create_issue_url
        req.body = payload.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = "JSESSIONID=#{session_token[:value]}"
      end

      Rails.logger.warn("Failed to create JIRA Feedaback Issue. Response: #{response}") unless response.success?
    end

    def authenticate!
      credentials = {
        username: TahiEnv.jira_username,
        password: TahiEnv.jira_password
      }
      auth_response = faraday_connection.post do |req|
        req.url TahiEnv.jira_authenticate_url
        req.body = credentials.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
      end
      auth_response_body = JSON.parse auth_response.body, symbolize_names: true
      raise if auth_response_body[:session].blank?
      auth_response_body[:session]
    end

    def build_payload(user, feedback_params)
      doi = Paper.find_by(id: feedback_params[:paper_id]).try(:doi)
      description = feedback_params[:remarks] + "\n\n"
      description += "Referrer: #{feedback_params[:referrer]} \n"
      description += "User Email: #{user.email} \n"
      description += "Tahi App Name: #{TahiEnv.app_name} \n"
      description += "Rails Env: #{Rails.env} \n"
      description += "Attachments:\n#{attachment_urls(feedback_params)}" if attachments_exist?(feedback_params)
      description += "\n\n"

      {
        fields: {
          summary: "Aperta Feedback from #{user.full_name}.",
          description: description,
          customfield_13439: aperta_environment,
          customfield_13500: user.username,
          customfield_13501: feedback_params[:browser],
          customfield_13502: feedback_params[:platform],
          customfield_13503: doi,
          project: {
            key: TahiEnv.jira_project
          },
          components: [{
            name: "Aperta"
          }],
          issuetype: {
            name: "Feedback"
          }
        }
      }
    end

    def aperta_environment
      aperta_env = {
        'development' => 'Vagrant/Local',
        'test'        => 'CircleCI',
        'staging'     => 'Heroku Review App'
      }[Rails.env]

      aperta_env ||= {
        'Aperta'           => 'Production',
        'Aperta (Stage)'   => 'Stage',
        'Aperta (QA-RC)'   => 'RC',
        'Aperta (DEV-CI)'  => 'CI/DEV',
        'Aperta (Demo)'    => 'Demo',
        'Aperta (Vagrant)' => 'Vagrant/Local'
      }[TahiEnv.app_name]

      aperta_env ? [{ value: aperta_env }] : []
    end

    def attachment_urls(feedback_params)
      feedback_params.dig(:screenshots).reduce("") do |result, screenshot|
        result + screenshot[:url] + "\n"
      end
    end

    def attachments_exist?(feedback_params)
      feedback_params.key?(:screenshots)
    end

    def faraday_connection
      @faraday_connection ||= Faraday.new do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
