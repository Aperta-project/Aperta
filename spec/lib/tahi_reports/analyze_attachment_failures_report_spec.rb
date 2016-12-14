require 'rails_helper'
require 'stringio'
require 'tahi_reports/analyze_attachment_failures_report'

describe TahiReports::AnalyzeAttachmentFailuresReport do
  describe 'running the report' do
    subject(:run_report) do
      described_class.run(output: output, attachment_klass: Attachment)
    end

    let(:output) { StringIO.new }
    def report_contents
      output.tap(&:rewind).read
    end

    let!(:processing_attachment_from_today) { FactoryGirl.create(:attachment, :processing, created_at: Date.today) }
    let!(:processing_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :processing, created_at: 1.week.ago) }
    let!(:processing_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :processing, created_at: 1.month.ago) }
    let!(:processing_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :processing, created_at: 1.year.ago) }

    let!(:errored_attachment_from_today) { FactoryGirl.create(:attachment, :errored, created_at: Date.today) }
    let!(:errored_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :errored, created_at: 1.week.ago, error_message: "Failed because of A") }
    let!(:errored_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :errored, created_at: 1.month.ago) }
    let!(:errored_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :errored, created_at: 1.year.ago, error_message: "Failed because of B") }

    let!(:completed_attachment_from_today) { FactoryGirl.create(:attachment, :completed, created_at: Date.today) }
    let!(:completed_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :completed, created_at: 1.week.ago) }
    let!(:completed_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :completed, created_at: 1.month.ago) }
    let!(:completed_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :completed, created_at: 1.year.ago) }

    let!(:unknown_state_attachment_from_today) { FactoryGirl.create(:attachment, :unknown_state, created_at: Date.today) }
    let!(:unknown_state_attachment_from_a_week_ago) { FactoryGirl.create(:attachment, :unknown_state, created_at: 1.week.ago) }
    let!(:unknown_state_attachment_from_a_month_ago) { FactoryGirl.create(:attachment, :unknown_state, created_at: 1.month.ago) }
    let!(:unknown_state_attachment_from_a_year_ago) { FactoryGirl.create(:attachment, :unknown_state, created_at: 1.year.ago) }

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
        Count in processing in the past 0 days: 1
        Count in processing in the past 1 day: 1
        Count in processing in the past 7 days: 1
        Count in processing in the past 14 days: 1
        Count in processing in the past 1 month: 1
        Count in processing in the past 1 year: 2
      STRING
    end

    it 'prints how many attachments are stuck in an errored state' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        Attachment(s) that errored out
        -------------------------------------------
        Count in error state in the past 0 days: 1
        Count in error state in the past 1 day: 1
        Count in error state in the past 7 days: 1
        Count in error state in the past 14 days: 1
        Count in error state in the past 1 month: 1
        Count in error state in the past 1 year: 2
      STRING
    end

    it 'prints a number of attachments per error breakdown including the database ids for each attachment' do
      run_report
      expect(report_contents).to include <<-STRING.strip_heredoc
        Errors in the past 0 days
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_today.id}]


        Errors in the past 1 day
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_today.id}]


        Errors in the past 7 days
          1 failed with error: Failed because of A
          ids=[#{errored_attachment_from_a_week_ago.id}]


        Errors in the past 14 days
          1 failed with error: Failed because of A
          ids=[#{errored_attachment_from_a_week_ago.id}]


        Errors in the past 1 month
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_a_month_ago.id}]


        Errors in the past 1 year
          1 failed with error: Failed for some reason
          ids=[#{errored_attachment_from_a_month_ago.id}]

          1 failed with error: Failed because of B
          ids=[#{errored_attachment_from_a_year_ago.id}]
      STRING
    end
  end
end
