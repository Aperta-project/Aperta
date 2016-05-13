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

  include_examples "snapshot serializes related nested questions", resource: :reviewer_recommendation
end
