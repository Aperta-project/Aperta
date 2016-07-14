require 'rails_helper'

describe BillingLogReport do
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

    context 'has paper to export' do
      let!(:paper) { create_paper_with_completed_billing }
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
        expect(report.csv.string).to include(csv_headers.join(','))
      end

      it 'includes paper data in csv file' do
        expect(report.csv.string).to include(
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
        expect(report.csv.string).to include(
          'No accepted papers with completed billing'
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
      create_paper_with_completed_billing
      expect(BillingLogReport.new.papers?).to be true
    end
  end

  def create_paper_with_completed_billing
    FactoryGirl.create(
      :paper_with_task,
      :accepted,
      :with_creator,
      task_params: {
        title: "Billing",
        type: "PlosBilling::BillingTask",
        completed: true }
    )
  end
end
