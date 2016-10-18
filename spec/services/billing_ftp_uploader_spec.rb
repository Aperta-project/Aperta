require 'rails_helper'
require 'stringio'

describe BillingFTPUploader do
  subject(:billing_ftp_uploader) do
    BillingFTPUploader.new(billing_log_report, logger: logger)
  end

  #
  # Collaborating BillingLogReport
  #
  let(:billing_log_report) do
    instance_double(
      BillingLogReport,
      csv: '1,2,3',
      papers_to_process: papers_to_process)
  end
  let(:papers_to_process) { [paper_1, paper_2] }
  let(:paper_1) { FactoryGirl.build_stubbed(:paper) }
  let(:paper_2) { FactoryGirl.build_stubbed(:paper) }

  #
  # Constructor parameters
  #
  let(:logger) { Logger.new(logger_io) }
  let(:logger_io) { StringIO.new }

  #
  # Collaborating service object
  #
  let(:ftp_uploader_service) do
    instance_double(FtpUploaderService, upload: nil)
  end

  #
  # Collaborating Journal
  #
  let(:staff_admins_across_all_journals) { [ staff_admin_1, staff_admin_2 ] }
  let(:staff_admins_for_paper_journals) { [ staff_admin_1 ] }
  let(:staff_admin_1) { FactoryGirl.build_stubbed(:user) }
  let(:staff_admin_2) { FactoryGirl.build_stubbed(:user) }

  #
  # Environment
  #
  let(:env_hash) do
    {
      'BILLING_FTP_ENABLED' => ftp_enabled,
      'BILLING_FTP_URL' => ftp_url
    }
  end
  let(:ftp_enabled) { 'true' }
  let(:ftp_url) { 'ftp://username:password@ftp.example.com' }

  # Run an around example to ensure we modify the environment
  around do |example|
    ClimateControl.modify env_hash do
      example.run
    end
  end

  before do
    allow(FtpUploaderService).to receive(:new).and_return ftp_uploader_service
    allow(Journal).to receive(:staff_admins_for_papers).and_return []
    allow(Journal).to receive(:staff_admins_across_all_journals).and_return []
  end

  describe '#initialize' do
    it 'raises an error for nil argument' do
      expect { BillingFTPUploader.new(nil) }.to raise_exception(
        ArgumentError,
        'The billing_log_report cannot be nil'
      )
    end
  end

  describe '#upload' do
    context 'when billing ftp is enabled' do
      let(:expected_filename) do
        upload_datetime = Time.zone.now.strftime "%Y%m%d-%H%M"
        "aperta-billing-#{upload_datetime}.csv"
      end

      let(:expected_error_detail) do
        "#{billing_log_report.papers_to_process.count} papers with the"\
        " following IDs were not sent to billing: "\
        "#{papers_to_process.map(&:id).join(', ')}"
      end

      context 'and the billing report has papers' do
        before do
          expect(billing_log_report.papers_to_process).to_not be_empty
        end

        it 'constructs an FtpUploaderService and uploads the report' do
          Timecop.freeze do
            expect(Journal).to receive(:staff_admins_for_papers).with(
              papers_to_process
            ).and_return staff_admins_for_paper_journals

            expect(FtpUploaderService).to receive(:new).with(
              file_io: billing_log_report.csv,
              final_filename: expected_filename,
              url: ftp_url,
              email_on_failure: staff_admins_for_paper_journals.map(&:email),
              error_detail: expected_error_detail
            ).and_return ftp_uploader_service

            billing_ftp_uploader.upload
          end
        end
      end

      context 'and the billing report has no papers' do
        let(:papers_to_process) { [] }

        before do
          expect(billing_log_report.papers_to_process).to be_empty
        end

        it 'constructs an FtpUploaderService and uploads the report' do
          Timecop.freeze do
            expect(Journal).to receive(:staff_admins_across_all_journals)
              .and_return staff_admins_across_all_journals

            expect(FtpUploaderService).to receive(:new).with(
              file_io: billing_log_report.csv,
              final_filename: expected_filename,
              url: ftp_url,
              email_on_failure: staff_admins_across_all_journals.map(&:email),
              error_detail: expected_error_detail
            ).and_return ftp_uploader_service

            billing_ftp_uploader.upload
          end
        end
      end

      it 'returns true' do
        expect(billing_ftp_uploader.upload).to eq(true)
      end
    end

    context 'when billing ftp is not enabled' do
      let(:ftp_enabled) { 'false' }
      let(:logged_content) { logger_io.tap(&:rewind).read }

      it 'does not upload anything' do
        expect(FtpUploaderService).to_not receive(:new)
      end

      it 'logs that it did not upload anything' do
        # override default logger formatter since we don't care what the
        # format for the application is set to, just that we're logging
        # correctly
        logger.formatter = lambda do |severity, datetime, progname, msg|
          "#{severity}: #{msg}"
        end

        Timecop.freeze do
          billing_ftp_uploader.upload
          expect(logged_content).to eq "WARN: Billing FTP is not enabled."
        end
      end

      it 'returns false' do
        expect(billing_ftp_uploader.upload).to eq(false)
      end
    end
  end
end
