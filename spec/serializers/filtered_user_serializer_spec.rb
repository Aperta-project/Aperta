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

    allow_any_instance_of(FakeFilteredUserSerializer).to receive(:current_user).and_return(user)
  end

  context "user is site admin" do
    let(:user) { create :user, :site_admin }

    it "does not serialize old roles" do
      JSON.parse(serialized_data).map do |u|
        expect(u["old_roles"]).to be_nil
      end
    end
  end

  context "user is journal admin" do
    let(:user) { create :user }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it "does not serialize old roles" do
      JSON.parse(serialized_data).map do |u|
        expect(u["old_roles"]).to be_nil
      end
    end
  end

  context "user is neither site nor journal admin" do
    let(:user) { create :user }

    it "does not serialize old roles" do
      JSON.parse(serialized_data).map do |u|
        expect(u["old_roles"]).to be_nil
      end
    end
  end
end
