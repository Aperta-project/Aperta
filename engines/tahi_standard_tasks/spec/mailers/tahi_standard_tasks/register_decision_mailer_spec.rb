require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionMailer do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) do
    FactoryGirl.create(:paper,
      :with_creator,
      journal: journal,
      title: "Paper Title")
  end

  let(:decision) do
    paper.decisions.create!(
      letter: "Body text of a Decision Letter",
      verdict: "accept"
    )
  end

  let(:email_with_no_fields_specified) do
    described_class.notify_author_email(to_field: nil, subject_field: nil, decision_id: decision.id)
  end

  describe "#notify_author_email" do
    context 'with to field and subject field empty' do
      it "sends email to the author with the correct subject and decision letter" do
        aggregate_failures do
          expect(email_with_no_fields_specified.to).to eq([paper.creator.email])
          expect(email_with_no_fields_specified.subject).to eq "A decision has been registered on the manuscript, \"#{paper.title}\""
          expect(email_with_no_fields_specified.body.raw_source).to match(decision.letter)
        end
      end
    end

    context 'with to field and subject field populated with custom values' do
      let(:email_to_arbitrary) do
        described_class.notify_author_email(to_field: 'arb@example.com', subject_field: 'Your Submission', decision_id: decision.id)
      end
      it "sends email to the author's email with a custom subject, containing the decision letter" do
        aggregate_failures do
          expect(email_to_arbitrary.to).to eq(['arb@example.com'])
          expect(email_to_arbitrary.subject).to eq 'Your Submission'
          expect(email_to_arbitrary.body.raw_source).to match(decision.letter)
        end
      end
    end

    context 'when mailing multiple recipients' do
      describe 'emails are separated by commas' do
        emails = 'john@example.com, mary@example.com, jane@example.com'
        let(:email_to_multiple_recipients) do
          described_class.notify_author_email(to_field: emails, subject_field: 'Subject', decision_id: decision.id)
        end
        it 'sends to all the recipients' do
          expect(email_to_multiple_recipients.to).to eq(['john@example.com', 'mary@example.com', 'jane@example.com'])
        end
      end

      describe 'emails are separated by semicolons' do
        emails = 'jack@yahoo.com;mary@gmail.com'
        let(:email_to_multiple_recipients) do
          described_class.notify_author_email(to_field: emails, subject_field: 'Subject', decision_id: decision.id)
        end
        it 'sends to all recipients' do
          expect(email_to_multiple_recipients.to).to eq(['jack@yahoo.com', 'mary@gmail.com'])
        end
      end
    end
  end
end
