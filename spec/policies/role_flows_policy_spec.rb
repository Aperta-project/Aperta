require 'rails_helper'

describe FlowsPolicy do
  let(:flow) { FactoryGirl.create(:flow) }
  let(:journal) { flow.role.journal }
  let(:policy) { FlowsPolicy.new(current_user: user, flow: flow) }

  context "user has an admin journal role" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can view role flow manager"
  end

  context "user is a site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can view role flow manager"
  end

  context "user is not a journal or site admin" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who can not view role flow manager"
  end
end
