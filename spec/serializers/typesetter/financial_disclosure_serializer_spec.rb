require 'rails_helper'

describe Typesetter::FinancialDisclosureSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:author_received_funding) { true }
  let(:funders) { [] }
  let(:task) do
    FactoryGirl.create(:financial_disclosure_task, funders: funders)
  end

  let(:output) { serializer.serializable_hash }

  before do
    NestedQuestionableFactory.create(
      task,
      questions: [
        {
          ident: 'financial_disclosures--author_received_funding',
          answer: author_received_funding,
          value_type: 'boolean'
        }
      ]
    )
  end

  it 'has competing interests fields' do
    expect(output.keys).to contain_exactly(
      :author_received_funding,
      :funding_statement,
      :funders)
  end

  describe 'author_recieved_funding' do
    it 'marks whether the author received funding' do
      expect(output[:author_received_funding]).to eq(author_received_funding)
    end
  end

  describe 'funding_statement' do
    it 'includes the funding statement from the task' do
      expect(output[:funding_statement]).to eq(task.funding_statement)
    end
  end

  describe 'funders' do
    let(:funders) { [FactoryGirl.create(:funder)] }
    let(:fake_serialized_funder) { 'Fake funder' }
    before do
      expect(Typesetter::FunderSerializer)
        .to receive(:new).and_return(
          instance_double('TypeSetter::FunderSerialiser',
                          serializable_hash: fake_serialized_funder))
    end

    it 'serializes the funders using the typesetter serializer' do
      expect(output[:funders]).to eq([fake_serialized_funder])
    end
  end
end
