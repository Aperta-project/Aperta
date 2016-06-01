require "rails_helper"

describe TahiStandardTasks::ReviewerReportTaskSerializer, serializer_test: true do
  let(:object_for_serializer) { reviewer_report_task }
  let(:reviewer_report_task) { FactoryGirl.build_stubbed :reviewer_report_task }
  let(:decision) { FactoryGirl.build_stubbed(:decision) }

  before do
    allow(reviewer_report_task).to receive(:decisions).and_return [decision]
    allow(reviewer_report_task).to receive(:submitted?).and_return true
  end

  let(:task_content) { deserialized_content[:task] }
  let(:decisions_content) { deserialized_content[:decisions] }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash

    expect(task_content).to match(hash_including(
      is_submitted: true,
      decision_ids: [decision.id]
    ))

    actual_decision_ids = decisions_content.map { |h| h[:id] }
    expect(actual_decision_ids).to contain_exactly(decision.id)
  end
end
