require "rails_helper"

describe ParticipationFactory do
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_task_participant_role
    )
  end

  describe '.create' do
    let(:assignee) { FactoryGirl.create(:user) }
    let(:assigner) { FactoryGirl.create(:user) }
    let(:full_params) { { task: task, assignee: assignee, assigner: assigner } }
    let(:same_params) { { task: task, assignee: assignee, assigner: assignee } }

    it 'does not sent notification when the notify flag is set to true' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(task: task, assignee: assignee, notify: false)
    end

    it 'queues up an email notification to the assignee' do
      expect(UserMailer).to receive_message_chain('delay.add_participant')
      ParticipationFactory.create(full_params)
    end

    it 'does not create a participation if already participant' do
      task.add_participant assignee
      expect do
        ParticipationFactory.create(full_params)
      end.to_not change { task.participations.count }
    end

    it 'creates a new participation assignment' do
      expect do
        ParticipationFactory.create(full_params)
      end.to change { task.participations.count }.by(1)
    end

    it 'does not email the assignee if is the same as the assigner' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(same_params)
    end
  end
end
