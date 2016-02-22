require 'rails_helper'

describe TaskSerializer do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }
  let(:serializer) { TaskSerializer.new(task) }

  subject do
    JSON.parse(serializer.to_json, symbolize_names: true)
  end

  describe '#is_metadata_task' do
    it 'returns false if task is not a metadata type' do
      expect(subject[:task][:is_metadata_task]).to eq(false)
    end

    it 'returns true if task is a metadata type' do
      Task.metadata_types << 'Task'
      expect(subject[:task][:is_metadata_task]).to eq(true)
      Task.metadata_types.delete('Task')
    end
  end

  describe '#is_submission_task' do
    it 'returns false if task is not a submission type' do
      expect(subject[:task][:is_submission_task]).to eq(false)
    end

    it 'returns true if task is a submission type' do
      Task.submission_types << 'Task'
      expect(subject[:task][:is_submission_task]).to eq(true)
      Task.submission_types.delete('Task')
    end
  end

  describe '#assigned_to_me' do
    let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }

    it 'returns false if current_user does not exists in the context' do
      expect(subject[:task][:assigned_to_me]).to eq(false)
    end

    context 'task with participations' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        task.add_participant user
      end

      context 'setting the user option in the serializer call' do
        let(:serializer) { TaskSerializer.new(task, scope: user) }
        it 'returns true if current_user exists in the context' do
          expect(subject[:task][:assigned_to_me]).to eq(true)
        end
      end
    end
  end
end
