require 'spec_helper'

describe FlowsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:flow) { FactoryGirl.create(:flow, user: user) }
  let(:policy) { FlowsPolicy.new(current_user: user, flow: flow) }

  context "user has a flow manager journal role" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :flow_manager)
    end

    include_examples "person who can view flow manager"
  end

  context "user has an admin journal role" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can view flow manager"
  end

  context "user is a site admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can view flow manager"
  end

  context "user is not an admin or flow manager" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who can not view flow manager"
  end
end
