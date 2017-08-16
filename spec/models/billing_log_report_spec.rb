require 'rails_helper'

describe BillingLogReport do
  def accepted_paper_with_completed_billing(accepted_date: Date.new(2015, 1, 1))
    FactoryGirl.create(
      :paper_with_task,
      :accepted,
      :with_creator,
      accepted_at: accepted_date,
      task_params: {
        title: "Billing",
        type: "PlosBilling::BillingTask",
        completed: true
      }
    )
  end

  let(:logger) do
    log = Logger.new(logger_io)
    log.formatter = lambda do |severity, datetime, progname, msg|
      "#{severity}: #{msg}\n"
    end
    log.level = 1
    log
  end

  let(:logger_io) { StringIO.new }
  let(:logged_content) { logger_io.tap(&:rewind).read }
  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

  before do
    BillingLogReport.logger = logger
  end

  context '#save_and_send_to_s3!' do
    let(:report) { BillingLogReport.new }
    let(:csv_data) { CSV.read(report.csv) }

    context 'has paper to export' do
      let!(:paper) { accepted_paper_with_completed_billing }
      let(:csv_headers) do
        [
          'ned_id', 'corresponding_author_ned_id',
          'corresponding_author_ned_email', 'title', 'journal'
        ]
      end

      before { report.save_and_send_to_s3! }

      it 'logs where it was saved on s3' do
        expect(logged_content).to match "Saved Billing log to uploads/billing_log_report/csv_file/#{report.id}/"
      end

      it 'creates a csv file' do
        expect(report.csv_file).to be_an_instance_of(BillingLogUploader)
      end

      it 'adds a header row to the csv' do
        expect(csv_data.first).to include(*csv_headers)
      end

      it 'includes paper data in csv file' do
        expect(csv_data.last).to include(
          paper.title, paper.journal.name,
          paper.creator.email, paper.manuscript_id
        )
      end

      it 'creates BillingLog records for each paper in report' do
        expect(BillingLog.count).to eq(1)
      end
    end

    context 'no papers to export' do
      before { report.save_and_send_to_s3! }

      it 'creates a csv file' do
        expect(report.csv_file).to be_an_instance_of(BillingLogUploader)
      end

      it 'csv has line stating no data' do
        expect(csv_data).to include(
          ['No accepted papers with completed billing']
        )
      end

      it 'creates no BillionLog records' do
        expect(BillingLog.count).to eq(0)
      end
    end
  end

  context '#papers?' do
    it 'returns false when no papers meet criteria for report' do
      expect(BillingLogReport.new.papers?).to be false
    end

    it 'returns true when paper(s) do meet criteria for report' do
      accepted_paper_with_completed_billing
      expect(BillingLogReport.new.papers?).to be true
    end
  end

  context '#papers_to_process' do
    it 'returns nil when no papers meet criteria for report' do
      expect(BillingLogReport.new.papers_to_process.count).to eq(0)
    end

    it 'returns all accepted papers that have a completed billing task' do
      FactoryGirl.create :paper, :accepted
      valid_paper = accepted_paper_with_completed_billing
      expect(BillingLogReport.new.papers_to_process).to eq([valid_paper])
    end

    it 'returns all papers which have not been previously sent' do
      sent_paper = accepted_paper_with_completed_billing
      FactoryGirl.create :activity, :uploaded_paper, subject: sent_paper
      accepted_paper_with_completed_billing
      expect(BillingLogReport.new.papers_to_process).not_to include(sent_paper)
    end
  end

  context 'on create create' do
    it 'logs that it was created' do
      billing_log = BillingLogReport.new
      billing_log.save
      expect(logged_content).to match('INFO: Billing log created')
    end
  end
end
