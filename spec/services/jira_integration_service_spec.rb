require 'rails_helper'

describe JIRAIntegrationService do
  subject { described_class }

  before do
    allow_any_instance_of(TahiEnv).to receive(:jira_authenticate_url).and_return 'https://jira.plos.org/jira/rest/auth/1/session'
    allow_any_instance_of(TahiEnv).to receive(:jira_create_issue_url).and_return 'https://example.com'
  end

  describe '#build_payload' do
    it 'should return a properly formatted hash' do
      payload = subject.build_payload('tim', 'talks')
      expect(payload.dig(:fields, :summary)).to match(/tim/)
      expect(payload.dig(:fields, :description)).to eq('talks')
    end
  end
end
