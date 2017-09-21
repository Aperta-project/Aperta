require 'rails_helper'

describe TaskSerializer, serializer_test: true do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, :with_loaded_card, paper: paper) }
  let(:object_for_serializer) { task }
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:serializer) { TaskSerializer.new(task, scope: user) }

  before do
    allow(user).to receive(:can?)
      .with(:view, task)
      .and_return true
  end

  describe '#is_metadata_task' do
    it 'returns false if task is not a metadata type' do
      expect(deserialized_content[:task][:is_metadata_task]).to eq(false)
    end

    it 'returns true if task is a metadata type' do
      Task.metadata_types << 'AdHocTask'
      expect(deserialized_content[:task][:is_metadata_task]).to eq(true)
      Task.metadata_types.delete('AdHocTask')
    end
  end

  describe '#is_snapshot_task' do
    it 'returns false when task is not snapshottable' do
      task.snapshottable = false
      expect(deserialized_content[:task][:is_snapshot_task]).to eq(false)
    end

    it 'returns true whe task is not snapshottable' do
      task.snapshottable = true
      expect(deserialized_content[:task][:is_snapshot_task]).to eq(true)
    end
  end

  describe '#is_submission_task' do
    it 'returns false if task is not a submission type' do
      expect(deserialized_content[:task][:is_submission_task]).to eq(false)
    end

    it 'returns true if task is a submission type' do
      Task.submission_types << 'AdHocTask'
      expect(deserialized_content[:task][:is_submission_task]).to eq(true)
      Task.submission_types.delete('AdHocTask')
    end

    context 'if the task has a card version' do
      let(:card_version) do
        FactoryGirl.create(
          :card_version,
          required_for_submission: required_for_submission
        )
      end
      let(:task) { FactoryGirl.create(:custom_card_task, paper: paper, card_version: card_version) }

      context 'and the card_version is required_for_submission' do
        let(:required_for_submission) { true }

        it 'returns true' do
          expect(deserialized_content[:task][:is_submission_task]).to eq(true)
        end
      end

      context 'and the card_version is NOT required_for_submission' do
        let(:required_for_submission) { false }

        it 'returns false' do
          expect(deserialized_content[:task][:is_submission_task]).to eq(false)
        end
      end
    end
  end

  describe '#assigned_to_me' do
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

    before do
      allow(task).to receive(:participations)
        .and_return []
    end

    it 'returns false if current_user does not exists in the context' do
      expect(deserialized_content[:task][:assigned_to_me]).to eq(false)
    end

    context 'and the user is participating in this task' do
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

  describe '#is_workflow_only_task' do
    context 'associated card is configured as only displaying on workflow page' do
      before do
        task.card.latest_published_card_version.update(workflow_display_only: true)
      end

      it 'returns true' do
        expect(deserialized_content[:task][:is_workflow_only_task]).to eq(true)
      end
    end

    context 'associated card is configured as not restricted to workflow page' do
      before do
        task.card.latest_published_card_version.update(workflow_display_only: false)
      end

      it 'returns false' do
        expect(deserialized_content[:task][:is_workflow_only_task]).to eq(false)
      end
    end
  end
end
