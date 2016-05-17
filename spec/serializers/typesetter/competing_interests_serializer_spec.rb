require 'rails_helper'

describe Typesetter::CompetingInterestsSerializer do
  subject(:serializer) { described_class.new(task) }

  let!(:task) do
    NestedQuestionableFactory.create(
      FactoryGirl.create(:competing_interests_task),
      questions: [
        {
          ident: 'competing_interests--has_competing_interests',
          answer: 'true',
          value_type: 'boolean',
          questions: [{
            ident: 'competing_interests--statement',
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

  it 'works without values' do
    allow(task).to receive(:answer_for).and_return(nil)
    output = serializer.serializable_hash

    expect(output[:competing_interests]).to eq(nil)
  end

  describe 'competing interests value' do
    it 'is the answer to the competing interests question' do
      expect(output[:competing_interests]).to eq(true)
    end
  end

  describe 'competing interests statement value' do
    it 'is the answer to the competing interests statement question' do
      expect(output[:competing_interests_statement]).to eq('entered statement')
    end
  end

  describe 'no competing interests statement' do
    let!(:no_competing_task) do
      NestedQuestionableFactory.create(
        FactoryGirl.create(:competing_interests_task),
        questions: [
          {
            ident: 'competing_interests',
            answer: 'false',
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

    it 'has the stock no competing interests statement' do
      output = Typesetter::CompetingInterestsSerializer.new(
        no_competing_task).serializable_hash

      expect(output[:competing_interests_statement]).to \
        eq('The authors have declared that no competing interests exist.')
    end
  end
end
