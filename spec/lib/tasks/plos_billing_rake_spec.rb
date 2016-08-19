require 'rails_helper'

describe "plos_billing namespace rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_academic_editor_user,
      :with_short_title,
      :with_creator,
      :accepted,
      journal: journal,
      short_title: 'my paper short'
    )
  end

  let(:billing_task) do
    FactoryGirl.create(
      :billing_task,
      :with_nested_question_answers,
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
    paper.phases.first.tasks.push(*[billing_task,
                                    financial_disclosure_task,
                                    final_tech_check_task])
  end

  let :run_rake_task do
    Rake::Task['plos_billing:upload_log_file_to_s3'].reenable
    Rake.application.invoke_task "plos_billing:upload_log_file_to_s3[#{paper.id}]"
  end

  describe 'plos_billing:upload_log_file_to_s3' do
    it "should upload a csv file" do
      run_rake_task
    end
  end

  describe 'plos_billing:generate_billing_log' do
    it "should run " do
      Rake::Task['plos_billing:generate_billing_log'].reenable
      Rake.application.invoke_task "plos_billing:generate_billing_log"
    end
  end

  describe 'plos_billing:generate_billing_log' do
    it 'creates BillingLogReport and FTPs resulting csv' do
      BillingLogReport.any_instance.should_receive :save_and_send_to_s3!
      BillingFTPUploader.any_instance.should_receive :upload
      Rake.application.invoke_task "plos_billing:daily_billing_log_export"
    end
  end
end
