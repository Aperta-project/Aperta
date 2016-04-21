require 'rails_helper'


# The following redefines current_user to avoid the verification of partial
# double. Have a look here:
#
# https://relishapp.com/rspec/rspec-mocks/v/3-0/docs/verifying-doubles/dynamic-classes

class FakeFilteredUserSerializer  < FilteredUserSerializer
  def current_user
    super
  end
end

describe FilteredUserSerializer do
  let(:journal) { create :journal }
  let(:paper) { create :paper, journal: journal }
  let(:collaborator) { create :user }
  let(:editor) { create :user }
  let(:reviewer) { create :user }
  let(:users) { [user, collaborator, editor, reviewer] }

  let(:serialized_data) do
    ActiveModel::ArraySerializer.new(users,
      each_serializer: FakeFilteredUserSerializer,
      paper_id: paper.id).to_json
  end

  let (:old_roles) do
    JSON.parse(serialized_data).map do |u|
      u["old_roles"].first
    end
  end

  before do
    JournalFactory.new(journal).ensure_default_roles_and_permissions_exist
    create :paper_role, :editor, user: editor, paper: paper
    create :paper_role, :reviewer, user: reviewer, paper: paper
    create :paper_role, :collaborator, user: collaborator, paper: paper

    allow_any_instance_of(FakeFilteredUserSerializer).to receive(:current_user).and_return(user)
  end

  context "user is site admin" do
    let(:user) { create :user, :site_admin }

    it "serializes all old_roles" do
      expect(old_roles).to include("editor", "reviewer", "collaborator")
    end
  end

  context "user is journal admin" do
    let(:user) { create :user }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it "serializes all old_roles" do
      expect(old_roles).to include("editor", "reviewer", "collaborator")
    end

  end

  context "user is neither site nor journal admin" do
    let(:user) { create :user }

    it "serializes only collaborator old_roles" do
      expect(old_roles).to include("collaborator")
      expect(old_roles).to_not include("editor", "reviewer")
    end
  end
end
