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

  let(:financial_disclosure_task) do
    FactoryGirl.create(:financial_disclosure_task, paper: paper)
  end

  let(:final_tech_check_task) do
    FactoryGirl.create(:final_tech_check_task, paper: paper)
  end

  before do
    FactoryGirl.create(:billing_log_report)
    CardLoader.load("PlosBilling::BillingTask")
    paper.phases.first.tasks.concat(
      [
        billing_task,
        financial_disclosure_task,
        final_tech_check_task
      ]
    )
  end

  it "creates BillingLogReport, FTPs resulting csv and adds Activity log" do
    BillingLogReport.any_instance.should_receive :save_and_send_to_s3!
    BillingFTPUploader.any_instance.should_receive(:upload) { true }
    Activity.should_receive(:create).with(hash_including(subject: paper))
    worker = PlosBillingLogExportWorker.new
    expect { worker.perform }.to change { BillingLogReport.count }.by(1)
  end
end
