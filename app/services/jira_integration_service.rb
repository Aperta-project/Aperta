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
      faraday_connection.post do |req|
        req.url TahiEnv.jira_create_issue_url
        req.body = payload.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = "JSESSIONID=#{session_token[:value]}"
      end
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

    def build_payload(user_full_name, remarks)
      CREATE_ISSUE_FIELDS.deep_merge(fields:
      {
        "summary": "Aperta Feedback from #{user_full_name}.",
        "description": remarks
      })
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
