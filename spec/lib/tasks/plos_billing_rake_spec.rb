require 'rails_helper'

describe "plos_billing namespace rake task" do
  before :all do
    Rake.application.rake_require 'tasks/plos_billing'
    Rake::Task.define_task(:environment)
  end

  let!(:paper) { create(:paper) }

  describe 'plos_billing:upload_log_file_to_s3' do
    let :run_rake_task do
      Rake::Task['plos_billing:upload_log_file_to_s3'].reenable
      Rake.application.invoke_task "plos_billing:upload_log_file_to_s3[#{paper.id}]"
    end

    it "should upload a csv file" do
      allow_any_instance_of(BillingLog).to receive(:to_s3)
      run_rake_task
    end
  end
end
