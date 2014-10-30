require 'spec_helper'

shared_examples_for "person who can manage plos authors" do
  it "allows all actions" do
    expect(policy.update?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot manage plos authors" do
  it "doesn't let them do anything" do
    expect(policy.update?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

describe PlosAuthors::PlosAuthorsPolicy do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:journal) { paper.journal }
  let(:task) { FactoryGirl.create(:plos_authors_task, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:policy) { PlosAuthors::PlosAuthorsPolicy.new(current_user: user, task: task) }

  context "unrelated user" do
    include_examples "person who cannot manage plos authors"
  end

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can manage plos authors"
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }

    include_examples "person who can manage plos authors"
  end

  context "task participant" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    before do
      FactoryGirl.create(:participation, participant: user, task: task)
    end

    include_examples "person who can manage plos authors"
  end

  context "allowed reviewer" do
    %i(reviewer editor).each do |role|
      let(:user) do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:paper_role, role, user: user, paper: paper)
        user
      end

      before do
        task.update_attribute(:role, 'reviewer')
      end

      include_examples "person who can manage plos authors"
    end
  end

  context "allowed manuscript information task" do
    let(:user) do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
      user
    end

    before do
      task.update_attribute(:role, 'author')
    end

    include_examples "person who can manage plos authors"
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal), ],
      )
    end

    include_examples "person who can manage plos authors"
  end

  context "user with can_view_assigned_manuscript_managers on this journal and is assigned to the paper." do
    let(:journal_role) { FactoryGirl.create(:role, journal: journal, can_view_assigned_manuscript_managers: true) }
    let(:user) do
      user = FactoryGirl.create(:user)
      user.roles << journal_role
      user
    end

    before do
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
    end

    include_examples "person who can manage plos authors"
  end
end
