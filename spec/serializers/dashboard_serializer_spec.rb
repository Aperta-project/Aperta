require 'spec_helper'

describe DashboardSerializer do
  describe ".papers" do
    let(:user) { FactoryGirl.create :user }

    before do
      allow_any_instance_of(DashboardSerializer).to receive(:user) { user }
    end

    it "should add 'My Papers' to the role_descriptions for all papers the user has created" do
      submitted_paper = FactoryGirl.create(:paper, user: user)
      serialized_paper = first_serialized_paper(submitted_paper)

      expect(serialized_paper.role_descriptions).to match_array ['My Paper']
    end

    it "Should add role descriptions for papers the user associated to by paper_roles" do
      associated_paper = FactoryGirl.create(:paper)
      create(:paper_role, :reviewer, paper: associated_paper, user: user)
      serialized_paper = first_serialized_paper(associated_paper)

      expect(serialized_paper.role_descriptions).to match_array ['Reviewer']
    end

    it "Can include both 'My Paper' and other roles in the description" do
      associated_paper = FactoryGirl.create(:paper, user: user)
      create(:paper_role, :reviewer, paper: associated_paper, user: user)
      serialized_paper = first_serialized_paper(associated_paper)

      expect(serialized_paper.role_descriptions).to match_array ['Reviewer', 'My Paper']
    end

    def first_serialized_paper(paper)
      DashboardSerializer.new(paper).papers.first
    end
  end
end
