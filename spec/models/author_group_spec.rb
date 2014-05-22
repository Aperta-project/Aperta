require 'spec_helper'

describe AuthorGroup do
  describe "#ordinalized_create" do
    let!(:paper) { FactoryGirl.create :paper, author_groups: [ FactoryGirl.create(:author_group) ]}
    it "increments the name of the new author group" do
      author_group = AuthorGroup.ordinalized_create({ paper_id: paper.id })
      expect(author_group.name).to eq "Second Author"
    end

    it "creates the new author group" do
      expect {
        AuthorGroup.ordinalized_create({ paper_id: paper.id })
      }.to change { AuthorGroup.count }.by 1
    end
  end

  describe "#build_default_groups_for" do
    it "sets the right names" do
      author_groups = AuthorGroup.build_default_groups_for(FactoryGirl.build(:paper))
      expect(author_groups.map(&:name)).to match_array([
        "First Author",
        "Second Author",
        "Third Author"
      ])
    end
  end
end
