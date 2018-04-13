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

require "rails_helper"

describe Snapshot::ReviewerRecommendationSerializer do
  subject(:serializer) { described_class.new(reviewer_recommendation) }
  let(:reviewer_recommendation) do
    FactoryGirl.create(:reviewer_recommendation,
                       first_name: "Last",
                       last_name: "First",
                       middle_initial: "A",
                       email: "email@email.com",
                       department: "Department of Department",
                       title: "A Title",
                       affiliation: "yes",
                       ringgold_id: "no"
                      )
  end

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "reviewer-recommendation",
        type: "properties"
      )
    end

    it "serializes the reviewer recommendation's properties" do
      expect(serializer.as_json[:children]).to include(
        { name: "id", type: "integer", value: reviewer_recommendation.id },
        { name: "first_name", type: "text", value: "Last" },
        { name: "last_name", type: "text", value: "First" },
        { name: "middle_initial", type: "text", value: "A" },
        { name: "email", type: "text", value: "email@email.com" },
        { name: "department", type: "text", value: "Department of Department" },
        { name: "title", type: "text", value: "A Title" },
        { name: "affiliation", type: "text", value: "yes" }
      )
    end
  end

  it_behaves_like "snapshot serializes related answers as nested questions", resource: :reviewer_recommendation
end
