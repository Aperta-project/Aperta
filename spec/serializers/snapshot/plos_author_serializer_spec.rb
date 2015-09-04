require "rails_helper"

describe Snapshot::PlosAuthorSerializer do
  let(:plos_author) { FactoryGirl.create :plos_author }

  it "generates a snapshot" do
    expected = {name: "author", type: "properties", children:
      [{name: "name", type: "text", value: "#{plos_author.first_name} #{plos_author.middle_initial} #{plos_author.last_name}"},
       {name: "email", type: "text", value: "#{plos_author.email}"},
       {name: "title", type: "text", value: "#{plos_author.title}"},
       {name: "department", type: "text", value: "#{plos_author.department}"},
       {name: "contributions", type: "properties", children:
         [{:name=>"contribution", :type=>"text", :value=>"bought cookies"}]
       },
       {name: "corresponding", type: "boolean", value: "#{plos_author.corresponding}"},
       {name: "deceased", type: "boolean", value: "#{plos_author.deceased}"},
       {name: "affiliation", type: "text", value: "#{plos_author.affiliation}"},
       {name: "secondary_affiliation", type: "text", value: "#{plos_author.secondary_affiliation}"}]}

    snapshot = Snapshot::PlosAuthorSerializer.new(author: plos_author).snapshot

    expect(snapshot).to match(expected)
  end

  it "handles empty optional fields" do
    plos_author.affiliation = nil
    plos_author.secondary_affiliation = nil
    plos_author.deceased = false
    plos_author.corresponding = false
    plos_author.contributions = nil
    expected = {name: "author", type: "properties", children:
      [{name: "name", type: "text", value: "#{plos_author.first_name} #{plos_author.middle_initial} #{plos_author.last_name}"},
       {name: "email", type: "text", value: "#{plos_author.email}"},
       {name: "title", type: "text", value: "#{plos_author.title}"},
       {name: "department", type: "text", value: "Jedis"},
       {name: "contributions", type: "properties", children: []},
       {name: "corresponding", type: "boolean", value: "false"},
       {name: "deceased", type: "boolean", value: "false"},
       {name: "affiliation", type: "text", value: ""},
       {name: "secondary_affiliation", type: "text", value: ""}]}

    snapshot = Snapshot::PlosAuthorSerializer.new(author: plos_author).snapshot

    expect(snapshot).to match(expected)
  end
end
