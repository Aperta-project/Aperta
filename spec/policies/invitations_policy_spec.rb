require 'rails_helper'

describe InvitationsPolicy do
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let(:invitation) { FactoryGirl.create(:invitation, paper: paper) }
  let(:policy) { InvitationsPolicy.new(current_user: user, invitation: invitation) }

  context "invitee" do
    let(:user) { invitation.invitee }

    include_examples "person who is an invitee"
  end

  context "non associated user" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who is not related to task"
  end
end
