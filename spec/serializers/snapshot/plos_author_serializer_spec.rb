require "rails_helper"

describe Snapshot::PlosAuthorSerializer do
  let(:plos_author) { FactoryGirl.create :plos_author }

  it "generates a snapshot" do
    expected = {name: "author", type: "properties", children:
      [{name: "name", type: "text", value: "Luke J Skywalker"},
       {name: "email", type: "text", value: "test-user-2@example.com"},
       {name: "title", type: "text", value: "Head Jedi"},
       {name: "department", type: "text", value: "Jedis"},
       {name: "corresponding", type: "text", value: "true"},
       {name: "deceased", type: "text", value: "true"},
       {name: "affiliation", type: "text", value: "university of dagobah"},
       {name: "secondary_affiliation", type: "text", value: ""}]}

    snapshot = Snapshot::PlosAuthorSerializer.new(author: plos_author).snapshot

    expect(snapshot).to match(expected)
  end
end
