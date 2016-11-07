require 'rails_helper'

describe ErrorSerializer, serializer_test: true do
  subject(:serializer) { described_class.new(message: error_message) }
  let(:error_message) { "Danger Will Robinson!" }
  
  describe '#as_json' do
    let(:json) { serializer.as_json[:error] }

    it 'serializes to JSON' do
      expect(json).to match hash_including(message: error_message)
    end
  end
end
