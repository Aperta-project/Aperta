# Service class to handle communication with JIRA
class JIRAIntegrationService
  include Singleton

  attr_reader :jira_session

  JIRA_BASE_PATH = 'https://jira.plos.org/jira'.freeze
  AUTHENTICATE_PATH = '/rest/auth/1/session'.freeze
  CREATE_ISSUE_PATH = '/rest/api/2/issue'.freeze

  CREATE_ISSUE_FIELDS = {
    "fields": {
      "project":
      {
        "key": "RT"
      },
      "components": [{
        "name": "Aperta"
      }],
      "issuetype": {
        "name": "Feedback"
      }
    }
  }.freeze

  def authenticate!
    credentials = {
      username: ENV['JIRA_USER'],
      password: ENV['JIRA_PASS']
    }
    auth_response = RestClient.post JIRA_BASE_PATH + AUTHENTICATE_PATH, credentials.to_json, content_type: :json, accept: :json
    auth_response = JSON.parse auth_response, symbolize_names: true
    return if auth_response[:session].blank?
    @jira_session = auth_response[:session]
  end

  def create_issue(user_full_name, options)
    authenticate!
    payload = CREATE_ISSUE_FIELDS.deep_merge(fields:
    {
      "summary": "Aperta Feedback from #{user_full_name}.",
      "description": options['remarks']
    })
    request_options = {
      content_type: :json,
      accept: :json,
      cookies: { "JSESSIONID": @jira_session[:value] }
    }
    RestClient.post JIRA_BASE_PATH + CREATE_ISSUE_PATH, payload.to_json, request_options
  end

  def clear_session
    @jira_session = nil
  end
end
