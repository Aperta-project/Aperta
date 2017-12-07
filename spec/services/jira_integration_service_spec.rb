require 'rails_helper'

describe JIRAIntegrationService do
  subject { described_class }

  describe '#build_payload' do
    let(:user) { FactoryGirl.create(:user, first_name: 'Barbara', last_name: 'Foo') }
    let(:params) { { remarks: 'talks' } }
    it 'should return a properly formatted hash' do
      payload = subject.build_payload(user, params)
      expect(payload.dig(:fields, :summary)).to include(user.full_name)
      expect(payload.dig(:fields, :description)).to include('talks')
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
        payload = subject.build_payload(user, params)
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
        payload = subject.build_payload(user, params_with_multiple_attachments)
        expect(payload.dig(:fields, :description)).to match(/awesomeness\.gif/)
        expect(payload.dig(:fields, :description)).to match(/ssenemosewa\.gif/)
      end
    end
  end
end
