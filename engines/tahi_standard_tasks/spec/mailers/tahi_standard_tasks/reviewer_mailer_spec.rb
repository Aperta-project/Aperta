require 'rails_helper'

describe TahiStandardTasks::ReviewerMailer do
  include ClientRouteHelper

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
    FactoryGirl.create :review_duration_period_setting_template
    FactoryGirl.create :feature_flag, name: "REVIEW_DUE_AT"
  end

  describe ".notify_invited" do
    subject(:email) do
      described_class.notify_invited(invitation_id: invitation.id)
    end

    let(:invitation) do
      FactoryGirl.create(:invitation, body: "Hiya, chief!", task: task)
    end

    let(:task) { FactoryGirl.create(:paper_reviewer_task) }

    it "has the correct subject line" do
      expect(email.subject).to eq "You have been invited as a reviewer for the manuscript, \"#{task.paper.display_title}\""
    end

    it "has the correct body content" do
      expect(email.body).to include "Hiya, chief!"
      expect(email.body).to include invitation.body
    end

    it "sends the email to the invitee's email" do
      expect(email.to).to contain_exactly(invitation.email)
    end

    it "does not bcc if the journal setting is nil" do
      expect(invitation.paper.journal.reviewer_email_bcc).to be_nil
      expect(email.bcc).to be_empty
    end

    it "attaches attachments on the invitation" do
      invitation.attachments << FactoryGirl.build(
        :invitation_attachment,
        file: File.open(Rails.root.join("spec/fixtures/bill_ted1.jpg"))
      )
      invitation.attachments << FactoryGirl.build(
        :invitation_attachment,
        file: File.open(Rails.root.join("spec/fixtures/yeti.gif"))
      )

      expect(email.attachments.length).to eq(2)
      expect(email.attachments.map(&:filename)).to contain_exactly(
        "bill_ted1.jpg",
        "yeti.gif"
      )
    end

    describe "when a bcc email address is provided" do
      before do
        invitation.paper.journal.update(reviewer_email_bcc: 'reviewer@example.com')
      end

      it "bcc's the journal setting to support chasing in Salesforce" do
        expect(email.bcc).to contain_exactly('reviewer@example.com')
      end
    end

    describe "links" do
      it "has a link to Aperta's dashboard for accepting the invitation in the email body" do
        expect(email.body).to include client_dashboard_url
      end

      it "has a link to decline the invitation in the email body" do
        expect(email.body).to include
        confirm_decline_invitation_url(invitation.token)
      end
    end
  end

  describe ".welcome_reviewer" do
    subject(:email) do
      described_class.welcome_reviewer(assignee_id: reviewer.id, paper_id: paper.id)
    end

    context "with a due date" do
      it "contains the due date" do
        report.set_due_datetime
        expect(report.due_at).to_not be_nil
        expect(email.body).to match(report.due_at.to_s(:due_with_minutes))
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

  shared_examples_for 'a Liquid email checked for blanks' do
    before do
      # rubocop:disable Rails/SkipsModelValidations
      report.paper.journal.tap { |j| j.update_attribute(:name, nil) }
      # rubocop:enable Rails/SkipsModelValidations
    end

    it 'raises a Bugsnag error if there are blank fields' do
      expect(Bugsnag).to receive(:notify)
      email.deliver_now
    end

    it 'does not send emails' do
      expect { email.deliver_now }.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end

  describe 'reminder emails' do
    before do
      report.paper.journal.letter_templates.create!(
        name: template_name,
        scenario: 'ReviewerReportScenario',
        subject: 'review {{ journal.name }}',
        body: '<p>Dear Dr. {{ reviewer.last_name }}, review {{ manuscript.title }} on {{ review.due_at }} </p>'
      )
      report.set_due_datetime
      report.save!
    end
    let(:report_due_at) { report.due_at.to_s(:due_with_hours) }

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
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report_due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end

      it_behaves_like 'a Liquid email checked for blanks'
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
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report_due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end

      it_behaves_like 'a Liquid email checked for blanks'
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
        expect(email.body).to match("<p>Dear Dr. #{report.user.last_name}, review #{report.paper.title} on #{report_due_at} </p>")
      end

      it 'renders the View Manuscript button' do
        expect(email.body).to match("View Manuscript")
      end

      it 'renders the signature' do
        expect(email.body).to match('Kind regards,')
      end

      it_behaves_like 'a Liquid email checked for blanks'
    end
  end

  describe '.thank_reviewer' do
    subject(:email) { described_class.thank_reviewer(reviewer_report_id: report.id) }
    let(:appreciation_email) { FactoryGirl.create(:letter_template, :thank_reviewer) }

    before { report.paper.journal.letter_templates << appreciation_email }

    it 'is addressed to the reviewer' do
      expect(email.to).to eq([report.user.email])
    end

    it 'renders the subject' do
      expect(email.subject).to eq("Thank you for reviewing #{report.paper.journal.name}")
    end

    it 'renders the email template' do
      expect(email.body).to match("Dear #{report.user.first_name} #{report.user.last_name}")
    end

    it 'renders the signature' do
      expect(email.body).to match('Kind regards')
      expect(email.body).to match(report.paper.journal.name)
    end

    it_behaves_like 'a Liquid email checked for blanks'
  end
end
