require 'spec_helper'

describe FlowsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:policy) { FlowsPolicy.new(current_user: user, journal: journal) }

  context "flow manager" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :flow_manager)
    end

    include_examples "person who can view flow manager"
  end

  context "admin" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can view flow manager"
  end
end
