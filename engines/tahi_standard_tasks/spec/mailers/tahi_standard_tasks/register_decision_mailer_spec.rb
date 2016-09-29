require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionMailer do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) do
    FactoryGirl.create(:paper,
      :with_creator,
      journal: journal,
      title: "Paper Title")
  end

  let(:task) do
    FactoryGirl.create(:task,
      title: "Register Decision Report",
      old_role: 'reviewer',
      type: "TahiStandardTasks::RegisterDecisionTask",
      paper: paper,
      completed: true)
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
      it "sends email to the author's email" do
        expect(email_with_no_fields_specified.to).to eq([paper.creator.email])
      end

      it "includes email subject" do
        expect(email_with_no_fields_specified.subject).to eq "A decision has been registered on the manuscript, \"#{paper.title}\""
      end

      it "email body is paper.decision_letter" do
        expect(email_with_no_fields_specified.body.raw_source).to match(decision.letter)
      end
    end

    context 'with to field and subject field populated with custom values' do
      let(:email_to_arbitrary) do
        described_class.notify_author_email(to_field: 'arb@example.com', subject_field: 'Your Submission', decision_id: decision.id)
      end
      it "sends email to the author's email" do
        expect(email_to_arbitrary.to).to eq(['arb@example.com'])
      end

      it "sends email with a custom subject" do
        expect(email_to_arbitrary.subject).to eq 'Your Submission'
      end

      it "email body is paper.decision_letter" do
        expect(email_to_arbitrary.body.raw_source).to match(decision.letter)
      end
    end
  end
end
