require 'rails_helper'

describe TaskSerializer, serializer_test: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }
  let(:object_for_serializer) { task }

  describe '#is_metadata_task' do
    it 'returns false if task is not a metadata type' do
      expect(deserialized_content[:task][:is_metadata_task]).to eq(false)
    end

    it 'returns true if task is a metadata type' do
      Task.metadata_types << 'Task'
      expect(deserialized_content[:task][:is_metadata_task]).to eq(true)
      Task.metadata_types.delete('Task')
    end
  end

  describe '#is_submission_task' do
    it 'returns false if task is not a submission type' do
      expect(deserialized_content[:task][:is_submission_task]).to eq(false)
    end

    it 'returns true if task is a submission type' do
      Task.submission_types << 'Task'
      expect(deserialized_content[:task][:is_submission_task]).to eq(true)
      Task.submission_types.delete('Task')
    end
  end

  describe '#assigned_to_me' do
    let(:paper) { FactoryGirl.build_stubbed(:paper) }
    let(:user) { FactoryGirl.build_stubbed(:user) }

    before do
      allow(task).to receive(:participations)
        .and_return []
    end

    it 'returns false if current_user does not exists in the context' do
      expect(deserialized_content[:task][:assigned_to_me]).to eq(false)
    end

    context 'and the user is participating in this task' do
      let(:serializer) { TaskSerializer.new(task, scope: user) }
      let(:participation_assignment) do
        FactoryGirl.build_stubbed(:assignment, user: user)
      end

      before do
        allow(task).to receive(:participations)
          .and_return [participation_assignment]
      end

      it 'returns true if current_user exists in the context' do
        expect(deserialized_content[:task][:assigned_to_me]).to eq(true)
      end
    end
  end
end
