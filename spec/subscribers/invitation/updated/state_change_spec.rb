# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
      FactoryGirl.create :review_duration_period_setting_template

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
