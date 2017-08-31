require 'rails_helper'

describe JIRAIntegrationService do
  subject { described_class.instance }

  it 'should be a singleton' do
    expect(JIRAIntegrationService.instance).to eq subject
  end

  describe '#authenticate!' do
    context 'successfully' do
      before do
        allow_any_instance_of(RestClient).to receive(:post).and_return "{\"session\":{\"name\":\"JSESSIONID\",\"value\":\"559C7096593C2750DE94950F437DBABE\"}}"
        subject.authenticate!
      end
      it 'should populate the session' do
        expect(subject.jira_session).not_to be blank?
      end
    end
    context 'unsuccessful' do
      before do
        allow_any_instance_of(RestClient).to receive(:post).and_return "{}"
        subject.authenticate!
      end
      it 'should indicate the error in the session' do
        expect(subject.jira_session).to be nil
      end
    end
  end

  describe '#create_issue' do
    it 'should have well-formed arguments'
  end
end
