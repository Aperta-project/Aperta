require 'rails_helper'
require 'stringio'
require 'tahi_reports/analyze_attachment_failures_report'

describe TahiReports::AnalyzeAttachmentFailuresReport do
  describe 'running the report' do
    # do not cache this value
    def run_report
      described_class.run(output: output, attachment_klass: Attachment)
    end

    # do not cache this value
    def report_contents
      output.tap(&:rewind).read
    end

    let(:output) { StringIO.new }

    let!(:processing_attachment_from_today) { FactoryGirl.create(:attachment, :processing, updated_at: 6.minutes.ago) }
    let!(:processing_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :processing, updated_at: 1.week.ago) }
    let!(:processing_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :processing, updated_at: 1.month.ago) }
    let!(:processing_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :processing, updated_at: 1.year.ago) }

    let!(:errored_attachment_from_today) { FactoryGirl.create(:attachment, :errored, updated_at: Date.today) }
    let!(:errored_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :errored, updated_at: 1.week.ago, error_message: "Failed because of A") }
    let!(:errored_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :errored, updated_at: 1.month.ago) }
    let!(:errored_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :errored, updated_at: 1.year.ago, error_message: "Failed because of B") }

    let!(:completed_attachment_from_today) { FactoryGirl.create(:attachment, :completed, updated_at: Date.today) }
    let!(:completed_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :completed, updated_at: 1.week.ago) }
    let!(:completed_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :completed, updated_at: 1.month.ago) }
    let!(:completed_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :completed, updated_at: 1.year.ago) }

    let!(:unknown_state_attachment_from_today) { FactoryGirl.create(:attachment, :unknown_state, updated_at: Date.today) }
    let!(:unknown_state_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :unknown_state, updated_at: 1.week.ago) }
    let!(:unknown_state_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :unknown_state, updated_at: 1.month.ago) }
    let!(:unknown_state_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :unknown_state, updated_at: 1.year.ago) }

    it 'outputs to the given IO object' do
      run_report
      expect(report_contents.present?).to be true
    end

    it 'prints a summary' do
      run_report
      expect(report_contents).to include "Below is the results of running the Attachment analysis report run on #{Date.today}."
      expect(report_contents).to include <<-STRING.strip_heredoc
        Total count of Attachment(s): 16
        -------------------------------------------
        # of done: 4
        # of processing: 4
        # of errored: 4
        # of unknown: 4
      STRING
    end

    it 'tells the reader of this report the purpose of the report' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        The goal of this email is to raise visibility of attachment processing issues before
        they become widespread so we can improve the experience of Aperta for its users.
        As issues arise it may be helpful to look for correlated errors in Bugsnag as well as
        in the `error_message` column on the `attachments` table in the production database.

        If an issue is found please create or update any related JIRA issues and communicate to
        PO/PMs as your earliest convenience.
      STRING
    end

    it 'prints a how many attachments are stuck in a processing state' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        Attachment(s) stuck in processing
        -------------------------------------------
        Count in processing state today: 1
        Count in processing state since yesterday: 1
        Count in processing state in the past week: 2
        Count in processing state in the past two weeks: 2
        Count in processing state in the past month: 3
        Count in processing state in the past year: 4
      STRING
    end

    it 'does not include attachments that have been processing for less than 5 minutes' do
      run_report
      current_report = report_contents
      expect(current_report).to include "Total count of Attachment(s): 16"
      expect(current_report).to include "Count in processing state today: 1"

      FactoryGirl.create(:attachment, :processing, updated_at: (4.minutes).ago)
      run_report
      current_report = report_contents

      # see that total count goes up
      expect(current_report).to include "Total count of Attachment(s): 17"

      # see that the number of processing attachments does not
      expect(current_report).to include "Count in processing state today: 1"
    end

    it 'prints how many attachments are stuck in an error state' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        Attachment(s) stuck in error
        -------------------------------------------
        Count in error state today: 1
        Count in error state since yesterday: 1
        Count in error state in the past week: 2
        Count in error state in the past two weeks: 2
        Count in error state in the past month: 3
        Count in error state in the past year: 4
      STRING
    end

    it 'prints a number of attachments per error breakdown including the database ids for each attachment' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        Errors today
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_today.id}]

        Errors since yesterday
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_today.id}]

        Errors in the past week
          1 failed with error: Failed because of A
          ids=[#{errored_attachment_from_a_week_ago.id}]

        Errors in the past two weeks
          1 failed with error: Failed because of A
          ids=[#{errored_attachment_from_a_week_ago.id}]

        Errors in the past month
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_a_month_ago.id}]

        Errors in the past year
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_a_month_ago.id}]

          1 failed with error: Failed because of B
          ids=[#{errored_attachment_from_a_year_ago.id}]
      STRING
    end
  end
end
