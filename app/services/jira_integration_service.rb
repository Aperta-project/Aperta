# Service class to handle communication with JIRA
class JIRAIntegrationService
  class << self
    CREATE_ISSUE_FIELDS = {
      "fields": {
        "project":
        {
          "key": TahiEnv.jira_project || "RT"
        },
        "components": [{
          "name": "Aperta"
        }],
        "issuetype": {
          "name": "Feedback"
        }
      }
    }.freeze

    def create_issue(user_full_name, options)
      session_token = authenticate!
      payload = build_payload(user_full_name, options['remarks'])
      request_options = build_request_options(session_token)
      RestClient.post TahiEnv.jira_create_issue_url, payload.to_json, request_options
    end

    def authenticate!
      credentials = {
        username: TahiEnv.jira_username,
        password: TahiEnv.jira_password
      }
      auth_response = RestClient.post TahiEnv.jira_authenticate_url, credentials.to_json, content_type: :json, accept: :json
      auth_response = JSON.parse auth_response, symbolize_names: true
      raise if auth_response[:session].blank?
      auth_response[:session]
    end

    def build_payload(user_full_name, remarks)
      CREATE_ISSUE_FIELDS.deep_merge(fields:
      {
        "summary": "Aperta Feedback from #{user_full_name}.",
        "description": remarks
      })
    end

    def build_request_options(session_token)
      {
        content_type: :json,
        accept: :json,
        cookies: { "JSESSIONID": session_token[:value] }
      }
    end
  end
end
