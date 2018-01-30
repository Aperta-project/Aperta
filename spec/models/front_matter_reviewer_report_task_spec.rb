require 'rails_helper'

describe FrontMatterReviewerReportTask do
  it_behaves_like 'a reviewer report task', factory: :front_matter_reviewer_report_task

  context 'DEFAULT_TITLE' do
    subject { FrontMatterReviewerReportTask::DEFAULT_TITLE }
    it { is_expected.to eq('Front Matter Reviewer Report') }
  end

  context 'DEFAULT_ROLE_HINT' do
    subject { FrontMatterReviewerReportTask::DEFAULT_ROLE_HINT }
    it { is_expected.to eq('reviewer') }
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults does not update title'
  end
end
