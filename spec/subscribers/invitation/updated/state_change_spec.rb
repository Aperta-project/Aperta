require 'rails_helper'

describe Invitation::Updated::StateChange do
  include EventStreamMatchers

  context "with a pending invitation" do
    let(:invitation) { FactoryGirl.build(:invitation) }

    it 'receives notification when the invite is sent' do
      Subscriptions.reload
      expect(described_class).to receive(:call)

      invitation.invite!
    end
  end

  context "with an associated reviewer report" do
    let(:reviewer) { FactoryGirl.create(:user) }
    let(:decision) { FactoryGirl.create(:decision) }
    let(:invitation) { FactoryGirl.create(:invitation) }
    let(:report) do
      FactoryGirl.create(:reviewer_report,
                                      decision: decision,
                                      user: reviewer)
    end

    before do
      decision.invitations << invitation
      decision.reviewer_reports << report
      Subscriptions.reload
    end

    context "with an invited invitation" do
      let(:invitation) do
        FactoryGirl.create(:invitation, :invited,
                                            decision: decision,
                                            invitee: reviewer)
      end

      it 'receives notification when the invite is accepted' do
        expect(described_class).to receive(:call)

        invitation.accept!
      end

      it 'updates the report status when the invitation is accepted' do
        invitation.accept!
        expect(report.reload.aasm.current_state).to eq(:review_pending)
      end
    end

    context "with an accepted invitation" do
      let(:report) do
        FactoryGirl.create(:reviewer_report,
                                        state: 'review_pending',
                                        decision: decision,
                                        user: reviewer)
      end
      let(:invitation) do
        FactoryGirl.create(:invitation, :accepted,
                                            decision: decision,
                                            invitee: reviewer)
      end

      it 'receives notification when the invite is rescinded' do
        expect(described_class).to receive(:call)

        invitation.rescind!
      end

      it 'updates report status when the invitation is accepted' do
        invitation.rescind!
        expect(report.reload.aasm.current_state).to eq(:invitation_not_accepted)
      end
    end
  end
end
