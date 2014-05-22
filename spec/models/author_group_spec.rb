require 'spec_helper'

describe AuthorGroup do
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
