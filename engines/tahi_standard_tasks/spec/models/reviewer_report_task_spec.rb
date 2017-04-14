require 'rails_helper'

describe TahiStandardTasks::ReviewerReportTask do
  it_behaves_like 'a reviewer report task', factory: :reviewer_report_task

  context 'DEFAULT_TITLE' do
    subject { TahiStandardTasks::ReviewerReportTask::DEFAULT_TITLE }
    it { is_expected.to eq('Reviewer Report') }
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults does not update title'
  end
end
