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
        completed: true }
    )
  end

  context '.create_paper' do
    context 'has from_date parameter' do
      it 'returns new BillingLogReport with given from date' do
        from_date = Date.new(2016, 1, 1)
        report = BillingLogReport.create_report(from_date: from_date)

        expect(report).to be_an_instance_of(BillingLogReport)
        expect(report.from_date).to eq(from_date)
      end
    end

    context 'not given from_date' do
      it 'returns new BillingLogReport with nil from_date' do
        report = BillingLogReport.create_report

        expect(report).to be_an_instance_of(BillingLogReport)
        expect(report.from_date).to be_nil
      end

      it 'returns new BillingLogReport data of last BillingLogReport' do
        existing_report = FactoryGirl.create(:billing_log_report)
        report = BillingLogReport.create_report

        expect(report).to be_an_instance_of(BillingLogReport)
        expect(report.from_date.to_s).to \
          eq(existing_report.created_at.strftime('%F'))
      end
    end
  end

  context '#save_and_send_to_s3!' do
    let(:report) { BillingLogReport.new }
    let(:csv_data) { CSV.read(report.csv) }

    context 'has paper to export' do
      let!(:paper) { accepted_paper_with_completed_billing }
      let(:csv_headers) do
        [
          'ned_id', 'corresponding_author_ned_id',
          'corresponding_author_ned_email', 'title', 'journal']
      end

      before { report.save_and_send_to_s3! }

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

    context 'with a from_date' do
      it 'returns all accepted papers whose accepted_at is after from_date, and have a completed billing task' do
        today = Time.zone.today
        accepted_paper_with_completed_billing
        new_paper = accepted_paper_with_completed_billing(accepted_date: today)
        report = BillingLogReport.new(from_date: today - 1.day)
        expect(report.papers_to_process).to eq([new_paper])
      end
    end
  end
end
