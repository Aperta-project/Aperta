require 'rails_helper'

describe IhatJobResponse do
  context 'normal response' do
    let(:response) { IhatJobResponse.new(state: 'pending') }
    it 'has a working pending? method' do
      expect(response.pending?).to be(true)
    end
  end
end
