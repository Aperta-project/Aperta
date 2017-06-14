require 'rails_helper'

describe IhatJobResponse do
  context 'normal response' do
    let(:response) { IhatJobResponse.new(state: 'pending', options: {}) }
    it 'has a working pending? method' do
      expect(response.pending?).to be(true)
    end
  end

  context 'errored response' do
    let(:response) { IhatJobResponse.new(state: 'errored', options: {}) }
    it 'has an errored job? method' do
      expect(response.errored?).to be(true)
    end
  end
end
