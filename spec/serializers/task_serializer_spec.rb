require "rails_helper"

describe TaskSerializer do
  describe "is_metadata_task" do
    before do
      PaperFactory.new(paper, user).create

      allow_any_instance_of(LitePaperSerializer).to receive(:roles).and_return([])
      allow_any_instance_of(LitePaperSerializer).to receive(:related_at_date).and_return(Time.zone.now)
    end

    let(:user) { FactoryGirl.create :user }
    let(:paper) { FactoryGirl.create :paper, creator: user }
    let(:task) { FactoryGirl.create :task, paper: paper }

    context "when the task is not a metadata task" do
      it "returns false" do
        serialized = JSON.parse TaskSerializer.new(task).to_json, symbolize_names: true
        expect(serialized[:task][:is_metadata_task]).to eq(false)
      end
    end

    context "when the task is a metadata task" do
      it "returns true" do
        Task.metadata_types << "Task"
        serialized = JSON.parse TaskSerializer.new(task).to_json, symbolize_names: true
        expect(serialized[:task][:is_metadata_task]).to eq(true)
        Task.metadata_types.delete("Task")
      end
    end
  end
end
