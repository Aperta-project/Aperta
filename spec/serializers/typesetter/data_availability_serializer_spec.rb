require 'rails_helper'

describe Typesetter::DataAvailabilitySerializer do
  subject(:serializer) { described_class.new(task) }

  let!(:task) do
    NestedQuestionableFactory.create(
      FactoryGirl.create(:data_availability_task),
      questions: [
        {
          ident: 'data_fully_available',
          answer: 'true',
          value_type: 'boolean'
        },
        {
          ident: 'data_location',
          answer: 'holodeck',
          value_type: 'text'
        }
      ]
    )
  end

  let(:output) { serializer.serializable_hash }

  it 'has data availability fields' do
    expect(output.keys).to contain_exactly(
      :data_fully_available,
      :data_location_statement)
  end

  describe 'data fully available value' do
    it 'is the answer to the data fully available question' do
      expect(output[:data_fully_available]).to eq(true)
    end
  end

  describe 'data location statement value' do
    it 'is the answer to the data location statement question' do
      expect(output[:data_location_statement]).to eq('holodeck')
    end
  end
end
