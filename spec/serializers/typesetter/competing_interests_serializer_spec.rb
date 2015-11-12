require 'rails_helper'

describe Typesetter::CompetingInterestsSerializer do
  subject(:serializer) { described_class.new(task) }

  let!(:task) do
    NestedQuestionableFactory.create(
      FactoryGirl.create(:competing_interests_task),
      questions: [
        {
          ident: 'competing_interests',
          answer: 'true',
          value_type: 'boolean',
          questions: [{
            ident: 'statement',
            answer: 'entered statement',
            value_type: 'text'
          }]
        }
      ]
    )
  end

  let(:output) { serializer.serializable_hash }

  it 'has competing interests fields' do
    expect(output.keys).to contain_exactly(
      :competing_interests,
      :competing_interests_statement)
  end

  describe 'competing interests value' do
    it 'is the answer to the competing interests quesiton' do
      expect(output[:competing_interests]).to eq(true)
    end
  end

  describe 'competing interests statement value' do
    it 'is the answer to the competing interests statement quesiton' do
      expect(output[:competing_interests_statement]).to eq('entered statement')
    end
  end
end
