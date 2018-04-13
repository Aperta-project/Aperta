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

describe Snapshot::ReviewerRecommendationsTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:reviewer_recommendations_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to eq(
        name: "reviewer-recommendations-task",
        type: "properties",
        children: [{ name: "id", type: "integer", value: task.id }]
      )
    end

    context "and it has reviewer recommendations" do
      let!(:reviewer_bob) { FactoryGirl.create(:reviewer_recommendation, id: 2) }
      let!(:reviewer_sally) { FactoryGirl.create(:reviewer_recommendation, id: 1) }

      let(:bobs_reviewer_serializer) do
        double(
          "Snapshot::ReviewerRecommendationSerializer",
          as_json: { recommendation: "bob's json here" }
        )
      end

      let(:sallys_reviewer_serializer) do
        double(
          "Snapshot::ReviewerRecommendationSerializer",
          as_json: { recommendation: "sally's json here" }
        )
      end

      before do
        task.reviewer_recommendations = [reviewer_bob, reviewer_sally]
        allow(Snapshot::ReviewerRecommendationSerializer).to receive(:new).with(reviewer_bob).and_return bobs_reviewer_serializer
        allow(Snapshot::ReviewerRecommendationSerializer).to receive(:new).with(reviewer_sally).and_return sallys_reviewer_serializer
      end

      it "serializes each reviewer(s) associated with the task in order by their respective id" do
        expect(serializer.as_json[:children]).to eq([
          { name: "id", type: "integer", value: task.id },
          { recommendation: "sally's json here" },
          { recommendation: "bob's json here" }
        ])
      end
    end
  end
end
