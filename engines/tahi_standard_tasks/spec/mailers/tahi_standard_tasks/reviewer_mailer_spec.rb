require 'rails_helper'

describe TahiStandardTasks::ReviewerMailer do
  let(:assigner) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }
  let(:reviewer) { FactoryGirl.create(:user) }
  let(:reviewer_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }
  let(:invitation) do
    FactoryGirl.create(
      :invitation,
      invitee: reviewer,
      inviter: assigner,
      email: reviewer.email,
      task: reviewer_task,
      decision: paper.draft_decision
    )
  end
  let(:report) do
    FactoryGirl.create(
      :reviewer_report,
      decision: paper.draft_decision,
      user: reviewer
    )
  end

  before do
    FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
  end

  describe ".welcome_reviewer" do
    subject(:email) do
      described_class.welcome_reviewer(assignee_id: reviewer.id, paper_id: paper.id)
    end

    context "with a due date" do
      it "contains the due date" do
        report.set_due_datetime
        expect(report.due_at).to_not be_nil
        expect(email.body).to match(report.due_at.strftime("%B %-d, %Y %H:%M %Z"))
      end
    end
  end

  describe ".reviewer_accepted" do
    subject(:email) do
      described_class.reviewer_accepted(invitation_id: invitation.id)
    end

    context "with an assigner" do
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
        expect(email.body).to match(%r{\/papers\/#{paper.short_doi}\/tasks\/#{reviewer_task.id}})
      end
    end

    context "without assigner" do
      let(:invitation) do
        FactoryGirl.create(
          :invitation,
          invitee: reviewer,
          inviter: nil,
          email: reviewer.email,
          task: reviewer_task
        )
      end

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end

    context "without reviewer existing in the system" do
      let(:invitation) do
        FactoryGirl.create(
          :invitation,
          invitee: nil,
          inviter: assigner,
          email: reviewer.email,
          task: reviewer_task
        )
      end

      it "does send" do
        expect(email.message).to be_a(Mail::Message)
      end

      it "includes the reviewer's email that was invited in the body" do
        expect(email.body).to match("#{invitation.email} has accepted")
      end
    end
  end

  describe ".reviewer_declined" do
    subject(:email) do
      described_class.reviewer_declined(invitation_id: invitation.id)
    end

    context "with an assigner" do
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
        expect(email.body).to match(%r{\/papers\/#{paper.short_doi}\/tasks\/#{reviewer_task.id}})
      end

      it "contains 'No feedback provided' for decline reason when not set" do
        expect(email.body).to match(/Reason:.*No feedback provided/)
      end

      it "contains 'None' for reviewer suggestions when not set" do
        expect(email.body).to match(/Reviewer Suggestions.*None/)
      end

      context 'invitee entered decline reason and reviewer suggestions' do
        before do
          invitation.update_attributes(
            decline_reason: 'Unable to review',
            reviewer_suggestions: 'Jane is available'
          )
        end

        it 'contains the decline reason' do
          expect(email.body).to match(invitation.decline_reason)
        end

        it 'contains the reviewer suggestions' do
          expect(email.body).to match(invitation.reviewer_suggestions)
        end
      end
    end

    context "without assigner" do
      let(:invitation) do
        FactoryGirl.create(
          :invitation,
          invitee: reviewer,
          inviter: nil,
          email: reviewer.email,
          task: reviewer_task
        )
      end

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end

    context "without reviewer existing in the system" do
      let(:invitation) do
        FactoryGirl.create(
          :invitation,
          invitee: nil,
          inviter: assigner,
          email: reviewer.email,
          task: reviewer_task
        )
      end

      it "does send" do
        expect(email.message).to be_a(Mail::Message)
      end

      it "includes the reviewer's email that was invited in the body" do
        expect(email.body).to match("#{invitation.email} has declined")
      end
    end
  end

  describe 'reminder emails' do
    before do
      report.paper.journal.letter_templates.create!(
        name: template_name,
        subject: 'review {{ journal.name }}',
        body: '<p>Dear Dr. {{ reviewer.last_name }}, review {{ paper.title }} on {{ review.due_at }} </p>'
      )
      report.set_due_datetime
      report.save!
    end

    describe '.remind_before_due' do
      subject(:email) { described_class.remind_before_due(reviewer_report_id: report.id) }
      let(:template_name) { 'Review Reminder - Before Due' }

      it 'is to the reviewer' do
        expect(email.to).to eq([report.user.email])
      end

      it 'renders the subject' do
        expect(email.subject).to eq("review #{report.paper.journal.name}")
      end

      it 'renders the email template' do
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report.due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end
    end

    describe '.first_late_notice' do
      subject(:email) { described_class.first_late_notice(reviewer_report_id: report.id) }
      let(:template_name) { 'Review Reminder - First Late' }

      it 'is to the reviewer' do
        expect(email.to).to eq([report.user.email])
      end

      it 'renders the subject' do
        expect(email.subject).to eq("review #{report.paper.journal.name}")
      end

      it 'renders the email template' do
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report.due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end
    end

    describe '.second_late_notice' do
      subject(:email) { described_class.second_late_notice(reviewer_report_id: report.id) }
      let(:template_name) { 'Review Reminder - Second Late' }

      it 'is to the reviewer' do
        expect(email.to).to eq([report.user.email])
      end

      it 'renders the subject' do
        expect(email.subject).to eq("review #{report.paper.journal.name}")
      end

      it 'renders the email template' do
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report.due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end
    end
  end
end
