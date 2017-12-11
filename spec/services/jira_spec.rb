require 'rails_helper'

describe Jira do
  subject { described_class }

  describe '#build_payload' do
    let(:user) { FactoryGirl.create(:user, first_name: 'Barbara', last_name: 'Foo') }
    let(:params) { { remarks: 'talks' } }
    it 'should return a properly formatted hash' do
      fields = subject.build_payload(user, params)[:fields]
      expect(fields[:summary]).to include(user.full_name)
      expect(fields[:description]).to include('talks')
    end

    it 'adds custom jira issue fields' do
      paper = FactoryGirl.create(:paper)
      params.merge!(
        browser: 'Firefox 42.3',
        platform: 'Platform 9',
        paper_id: paper.id
      )

      fields = subject.build_payload(user, params)[:fields]
      expect(fields[:customfield_13500]).to eq(user.username)
      expect(fields[:customfield_13501]).to eq('Firefox 42.3')
      expect(fields[:customfield_13502]).to eq('Platform 9')
      expect(fields[:customfield_13503]).to eq(paper.doi)
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
