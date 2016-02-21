require 'rails_helper'

describe FlowsPolicy do
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions)}
  let(:old_role) { FactoryGirl.create(:old_role, journal: journal)}
  let(:flow) { FactoryGirl.create(:flow, old_role: old_role) }
  let(:policy) { FlowsPolicy.new(current_user: user, flow: flow) }

  context "user has an admin journal old_role" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can view old_role flow manager"
  end

  context "user is a site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can view old_role flow manager"
  end

  context "user is not a journal or site admin" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who can not view old_role flow manager"
  end
end
