require "rails_helper"

describe Snapshot::AuthorSerializer do
  subject(:serializer) { described_class.new(author) }
  let(:author) do
    author = FactoryGirl.create(
      :author,
      first_name: "Reggie",
      last_name: "Watts",
      middle_initial: "U",
      email: "reggie@example.com",
      department: "Music",
      title: "Producer",
      affiliation: "Hip Hop",
      secondary_affiliation: "Another place",
      ringgold_id: "1234",
      secondary_ringgold_id: "9876"
    )
    author.position = 99
    author
  end

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "author",
        type: "properties"
      )
    end

    it "serializes the author's properties" do
      expect(serializer.as_json[:children]).to include(
        { name: "first_name", type: "text", value: "Reggie" },
        { name: "last_name", type: "text", value: "Watts" },
        { name: "middle_initial", type: "text", value: "U" },
        { name: "position", type: "integer", value: 99 },
        { name: "email", type: "text", value: "reggie@example.com" },
        { name: "department", type: "text", value: "Music" },
        { name: "title", type: "text", value: "Producer" },
        { name: "affiliation", type: "text", value: "Hip Hop" },
        { name: "secondary_affiliation", type: "text", value: "Another place" },
        { name: "ringgold_id", type: "text", value: "1234" },
        { name: "secondary_ringgold_id", type: "text", value: "9876" }
      )
    end

    it_behaves_like "snapshot serializes related nested questions", resource: :author
  end
end
