require 'rails_helper'

describe JIRAIntegrationService do
  subject { described_class }

  before do
    allow_any_instance_of(TahiEnv).to receive(:jira_authenticate_url).and_return 'https://example.com'
    allow_any_instance_of(TahiEnv).to receive(:jira_create_issue_url).and_return 'https://example.com'
  end

  describe '#authenticate!' do
    let!(:session_token) { "{\"session\":{\"name\":\"JSESSIONID\",\"value\":\"559C7096593C2750DE94950F437DBABE\"}}" }
    context 'successfully' do
      before do
        allow_any_instance_of(RestClient::Request).to receive(:execute).and_return session_token
      end
      it 'should populate the session' do
        expect(subject.authenticate!).not_to be blank?
      end
    end
  end

  describe '#build_payload' do
    it 'should return a properly formatted hash' do
      payload = subject.build_payload('tim', 'talks')
      expect(payload.dig(:fields, :summary)).to match(/tim/)
      expect(payload.dig(:fields, :description)).to eq('talks')
    end
  end

  describe '#build_request_options' do
    it 'should return a properly formatted hash' do
      session_token = "{\"session\":{\"name\":\"JSESSIONID\",\"value\":\"559C7096593C2750DE94950F437DBABE\"}}"
      session_token = JSON.parse(session_token)
      request_options = subject.build_request_options(session_token)
      expect(request_options.dig(:cookies)).to have_key(:JSESSIONID)
      expect(request_options.dig(:cookies, :JSESSIONID)).to eq(session_token.dig(:session, :value))
    end
  end
end
