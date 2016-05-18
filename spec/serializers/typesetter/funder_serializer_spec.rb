require 'rails_helper'

describe Typesetter::FunderSerializer do
  subject(:serializer) { described_class.new(funder) }
  let(:name) { 'Steven M Mercator' }
  let(:grant_number) { '12345F' }
  let(:website) { 'google.com' }
  let(:had_influence) { true }
  let(:influence_description) { 'this is an influence description' }
  let(:funder) do
    FactoryGirl.create(
      :funder,
      name: name,
      grant_number: grant_number,
      website: website
    )
  end

  before do
    NestedQuestionableFactory.create(
      funder,
      questions: [
        {
          ident: 'funder--had_influence',
          answer: had_influence,
          value_type: 'boolean',
          questions: [{
            ident: 'funder--had_influence--role_description',
            answer: influence_description,
            value_type: 'text'
          }]
        }
      ]
    )
  end

  let(:output) { serializer.serializable_hash }

  it 'has the correct fields' do
    expect(output.keys).to contain_exactly(
      :additional_comments,
      :name,
      :funding_statement,
      :grant_number,
      :website,
      :influence,
      :influence_description)
  end

  describe 'funding_statement' do
    it "returns a full funding statement" do
      expect(output[:funding_statement]).to eq(
        "#{output[:name]} #{output[:website]} (grant number #{output[:grant_number]}). #{output[:influence_description]}.")
    end
  end

  describe 'name' do
    it "is the funder's name" do
      expect(output[:name]).to eq(name)
    end
  end

  describe 'grant_number' do
    it "is the funder's grant number" do
      expect(output[:grant_number]).to eq(grant_number)
    end
  end

  describe 'website' do
    it "is the funder's website" do
      expect(output[:website]).to eq(website)
    end
  end

  describe 'influence' do
    it 'is a boolean of whether funder had influence' do
      expect(output[:influence]).to eq(had_influence)
    end
  end

  describe 'influence_description' do
    it "is a description of the funder's influence" do
      expect(output[:influence_description]).to eq(influence_description)
    end
  end
end
