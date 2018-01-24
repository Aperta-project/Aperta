require "rails_helper"

describe TahiStandardTasks::FrontMatterReviewerReportTaskSerializer, serializer_test: true do
  let(:object_for_serializer) { reviewer_report_task }
  let(:reviewer_report_task) { FactoryGirl.build_stubbed :front_matter_reviewer_report_task }
  let(:decision) { FactoryGirl.build_stubbed(:decision) }

  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:serializer) {
    TahiStandardTasks::FrontMatterReviewerReportTaskSerializer.new(object_for_serializer,
                                                                   scope: user)
  }

  before do
    allow(reviewer_report_task.paper).to receive('decisions').and_return [decision]
    allow(reviewer_report_task).to receive(:submitted?).and_return true
    allow(reviewer_report_task).to receive(:display_status).and_return :submitted

    allow(user).to receive(:can?)
      .with(:view, object_for_serializer)
      .and_return true
  end

  let(:task_content) { deserialized_content[:task] }
  let(:decisions_content) { deserialized_content[:decisions] }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash

    expect(task_content).to match(hash_including(
      is_submitted: true,
      decision_ids: [decision.id]
    ))
  end
end
