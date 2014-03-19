require 'spec_helper'

describe StandardTasks::ReviewerReportTask do
  describe "defaults" do
    subject(:task) { StandardTasks::ReviewerReportTask.new }
    specify { expect(task.title).to eq 'Reviewer Report' }
    specify { expect(task.role).to eq 'reviewer' }
  end
end
