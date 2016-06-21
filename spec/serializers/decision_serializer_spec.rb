require 'rails_helper'

describe DecisionSerializer, serializer_test: true do
  let(:paper) { FactoryGirl.build(:paper) }
  let(:decision) { FactoryGirl.create(:decision, paper: paper) }

  let(:object_for_serializer) { decision }

  it 'serializes the decision properties' do
    expect(serializer.as_json[:decision])
      .to include(
        author_response: decision.author_response,
        id: decision.id,
        invitation_ids: decision.invitation_ids,
        is_latest: decision.latest?,
        letter: decision.letter,
        paper_id: paper.id,
        revision_number: decision.revision_number,
        verdict: decision.verdict
      )
  end

  it 'serializes the decision paper' do
    expect(serializer.as_json[:papers].length).to eq(1)

    serialized_paper = serializer.as_json[:papers].first
    expect(serialized_paper[:id]).to eq(paper.id)
    expect(serialized_paper[:publishing_state]).to eq(paper.publishing_state)
  end
end
