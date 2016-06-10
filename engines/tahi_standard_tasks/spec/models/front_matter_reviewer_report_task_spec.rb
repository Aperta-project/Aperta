require 'rails_helper'

describe TahiStandardTasks::FrontMatterReviewerReportTask do
  include_examples 'a reviewer report task', factory: :front_matter_reviewer_report_task

  context 'DEFAULT_TITLE' do
    subject { TahiStandardTasks::FrontMatterReviewerReportTask::DEFAULT_TITLE }
    it { is_expected.to eq('Front Matter Reviewer Report') }
  end

  context 'DEFAULT_ROLE' do
    subject { TahiStandardTasks::FrontMatterReviewerReportTask::DEFAULT_ROLE }
    it { is_expected.to eq('reviewer') }
  end
end
