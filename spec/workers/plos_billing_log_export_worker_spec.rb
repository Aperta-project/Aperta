require 'rails_helper'

describe PlosBillingLogExportWorker do
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_academic_editor_user,
      :with_short_title,
      :with_creator,
      :accepted,
      journal: journal,
      short_title: 'my paper short',
      accepted_at: Time.now.utc
    )
  end

  let(:billing_task) do
    FactoryGirl.create(
      :billing_task,
      :with_card_content,
      completed: true,
      paper: paper
    )
  end

  let(:final_tech_check_task) do
    FactoryGirl.create(:final_tech_check_task, paper: paper)
  end

  let(:report) { FactoryGirl.create(:billing_log_report) }
  let(:uploader) { double(BillingFTPUploader) }

  before do
    CardLoader.load("PlosBilling::BillingTask")
    paper.phases.first.tasks.concat(
      [
        billing_task,
        final_tech_check_task
      ]
    )
  end

  it "creates BillingLogReport, FTPs resulting csv and adds Activity log" do
    expect(BillingLogReport).to receive(:create!).and_return(report)
    expect(report).to receive(:save_and_send_to_s3!)
    expect(report).to receive(:papers_to_process).and_return([paper])
    expect(BillingFTPUploader).to receive(:new).with(report).and_return(uploader)
    expect(uploader).to receive(:upload).and_return(true)
    expect(Activity).to receive(:create).with(hash_including(subject: paper))
    PlosBillingLogExportWorker.new.perform
  end
end
