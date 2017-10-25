require 'rails_helper'

describe JIRAIntegrationService do
  subject { described_class }

  before do
    allow_any_instance_of(TahiEnv).to receive(:jira_authenticate_url).and_return 'https://jira.plos.org/jira/rest/auth/1/session'
    allow_any_instance_of(TahiEnv).to receive(:jira_create_issue_url).and_return 'https://example.com'
  end

  describe '#build_payload' do
    let(:params) { { remarks: 'talks' } }
    it 'should return a properly formatted hash' do
      payload = subject.build_payload('tim', params)
      expect(payload.dig(:fields, :summary)).to match(/tim/)
      expect(payload.dig(:fields, :description)).to eq('talks')
    end

    context 'with one attachment' do
      let(:params) do
        {
          remarks: 'talks',
          screenshots: [
            { url: 'http://example.com/file?name=awesomeness.gif', name: 'Awesomeness' }
          ]
        }
      end
      it 'should attach a link to the attachment' do
        payload = subject.build_payload('tim', params)
        expect(payload.dig(:fields, :description)).to match(/awesomeness\.gif/)
      end
    end

    context 'with multiple attachments' do
      let(:params_with_multiple_attachments) do
        {
          remarks: 'talks',
          screenshots: [
            { url: 'http://example.com/file?name=awesomeness.gif', name: 'Awesomeness' },
            { url: 'http://example.com/file?name=ssenemosewa.gif', name: 'ssenemosewA' }
          ]
        }
      end

      it 'should attach the links to the attachments' do
        payload = subject.build_payload('tim', params_with_multiple_attachments)
        expect(payload.dig(:fields, :description)).to match(/awesomeness\.gif/)
        expect(payload.dig(:fields, :description)).to match(/ssenemosewa\.gif/)
      end
    end
  end
end
