require 'rails_helper'

describe CollaborationsPolicy do
  let(:policy) { CollaborationsPolicy.new(current_user: user, paper: paper) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper) }

    include_examples "person who can edit a paper's collaborators"
  end

  context "authors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, creator: user) }

    include_examples "person who can edit a paper's collaborators"
  end

  context "paper admins" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :admin, user: user, paper: paper)
    end

    include_examples "person who can edit a paper's collaborators"
  end

  context "paper editors" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :editor, user: user, paper: paper)
    end

    include_examples "person who can edit a paper's collaborators"
  end

  context "paper reviewers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :reviewer, user: user, paper: paper)
    end

    include_examples "person who can edit a paper's collaborators"
  end

  context "paper collaborators" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    before do
      create(:paper_role, :collaborator, user: user, paper: paper)
    end

    include_examples "person who can edit a paper's collaborators"
  end

  context "non-associated user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }

    include_examples "person who cannot edit a paper's collaborators"
  end
end
