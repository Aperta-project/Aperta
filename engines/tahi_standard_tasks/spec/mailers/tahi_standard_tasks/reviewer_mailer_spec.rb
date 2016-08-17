require 'rails_helper'

describe TahiStandardTasks::ReviewerMailer do
  let(:assigner) { FactoryGirl.create(:user) }
  let(:paper) { reviewer_task.paper }
  let(:reviewer) { FactoryGirl.create(:user) }
  let(:reviewer_task) { FactoryGirl.create(:task) }

  describe ".reviewer_accepted" do
    context "with an assigner" do
      let(:email) do
        described_class.reviewer_accepted(
          invite_reviewer_task_id: reviewer_task.id,
          reviewer_id: reviewer.id,
          assigner_id: assigner.id)
      end

      it "has correct subject line" do
        expect(email.subject).to eq "Reviewer invitation was accepted on the manuscript, \"#{paper.display_title}\""
      end

      it "sends to the assigner" do
        expect(email.to).to match_array(assigner.email)
      end

      it "contains the paper title" do
        expect(email.body).to match(reviewer_task.paper.title)
      end

      it "contains link to the task" do
        expect(email.body).to match(%r{\/papers\/#{paper.id}\/tasks\/#{reviewer_task.id}})
      end
    end

    context "without assigner" do
      let(:email) do
        described_class.reviewer_accepted(
          invite_reviewer_task_id: reviewer_task.id,
          reviewer_id: reviewer.id,
          assigner_id: nil)
      end

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe ".reviewer_declined" do
    let(:invitation) { FactoryGirl.create(:invitation) }

    context "with an assigner" do
      let(:email) do
        described_class.reviewer_declined(
          invite_reviewer_task_id: reviewer_task.id,
          invitation_id: invitation.id,
          reviewer_id: reviewer.id,
          assigner_id: assigner.id)
      end

      it "has correct subject line" do
        expect(email.subject).to eq "Reviewer invitation was declined on the manuscript, \"#{paper.display_title}\""
      end

      it "sends to the assigner" do
        expect(email.to).to match_array(assigner.email)
      end

      it "contains the paper title" do
        expect(email.body).to match(reviewer_task.paper.title)
      end

      it "contains link to the task" do
        expect(email.body).to match(%r{\/papers\/#{paper.id}\/tasks\/#{reviewer_task.id}})
      end

      it 'contains n/a for decline reason when not set' do
        expect(email.body).to match(%r{<strong>Reason:\s</strong>.+n/a})
      end

      it 'contains n/a for reviewer suggestions when not set' do
        expect(email.body).to match(
          %r{<strong>Reviewer\sSuggestions:\s</strong>.+n/a}
        )
      end

      context 'invitee entered decline reason and reviewer suggestions' do
        before do
          invitation.update_attributes(
            decline_reason: 'Unable to review << this paper is bad',
            reviewer_suggestions: "Jane is available, <em>she's great</em>")
        end

        it 'contains the decline reason, html escaped' do
          expect(email.body).to include "Unable to review &lt;&lt; this paper is bad"
        end

        it 'contains the reviewer suggestions, html escaped' do
          expect(email.body).to include "Jane is available, &lt;em&gt;she's great&lt;/em&gt;"
        end
      end
    end

    context "without assigner" do
      let(:email) do
        described_class.reviewer_declined(
          invite_reviewer_task_id: reviewer_task.id,
          invitation_id: invitation.id,
          reviewer_id: reviewer.id,
          assigner_id: nil)
      end

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
