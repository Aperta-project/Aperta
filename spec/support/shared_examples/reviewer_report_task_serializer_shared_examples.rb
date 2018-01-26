RSpec.shared_examples_for :reviewer_report_task_serializer do
  let(:task_class) { described_class.name.gsub(/Serializer$/, '').constantize }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:reviewer_report) do
    FactoryGirl.create(
      :reviewer_report,
      paper: paper,
      decision: decision,
      task: reviewer_report_task
    )
  end
  let(:reviewer_report_task) do
    FactoryGirl.create(
      task_class.name.demodulize.underscore.to_sym,
      paper: paper
    )
  end
  let(:object_for_serializer) { reviewer_report_task }
  let(:decision) { FactoryGirl.create(:decision, paper: paper) }
  let(:user) { FactoryGirl.create(:user) }
  let(:serializer) { described_class.new(reviewer_report_task, scope: user) }

  before do
    allow(reviewer_report_task).to receive(:submitted?).and_return true
    allow(reviewer_report_task).to receive(:display_status).and_return :submitted

    allow(user).to receive(:can?)
      .with(:view, reviewer_report_task)
      .and_return true
  end

  let(:task_content) { deserialized_content[:task] }
  let(:decisions_content) { deserialized_content[:decisions] }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
    expect(task_content).to match(
      hash_including(
        is_submitted: true,
        decision_ids: [decision.id]
      )
    )

    actual_decision_ids = decisions_content.map { |h| h[:id] }
    expect(actual_decision_ids).to contain_exactly(decision.id)
  end
end
