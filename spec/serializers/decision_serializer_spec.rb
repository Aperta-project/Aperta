# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe DecisionSerializer, serializer_test: true do
  let(:paper) { FactoryGirl.build(:paper) }
  let(:decision) { FactoryGirl.create(:decision, paper: paper) }

  let(:object_for_serializer) { decision }

  it 'serializes the decision properties' do
    expect(serializer.as_json[:decision])
      .to include(
        author_response: decision.author_response,
        created_at: decision.created_at,
        draft: decision.draft?,
        id: decision.id,
        initial: decision.initial?,
        invitation_ids: decision.invitation_ids,
        latest_registered: decision.latest_registered?,
        letter: decision.letter,
        major_version: decision.major_version,
        minor_version: decision.minor_version,
        paper_id: paper.id,
        registered_at: decision.registered_at,
        rescindable: decision.rescindable?,
        rescinded: decision.rescinded,
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
