require "rails_helper"

describe ParticipationFactory do
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal)}
  let(:task) { FactoryGirl.create(:task, paper: paper) }

  describe '.create' do
    let(:assignee) { FactoryGirl.create(:user) }
    let(:assigner) { FactoryGirl.create(:user) }
    let(:full_params) { { task: task, assignee: assignee, assigner: assigner } }
    let(:same_params) { { task: task, assignee: assignee, assigner: assignee } }

    it 'Do not sent notification if the notify flag is set to true' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(task: task, assignee: assignee, notify: false)
    end

    it 'Sent an email notification to the assignee' do
      expect(UserMailer).to receive_message_chain('delay.add_participant')
      ParticipationFactory.create(full_params)
    end

    it 'Does not create a participation if already participant' do
      task.add_participant assignee
      expect do
        ParticipationFactory.create(full_params)
      end.to_not change(Participation, :count)
    end

    it 'Creates a new participation assignment' do
      expect do
        ParticipationFactory.create(full_params)
      end.to change { task.participations.count }.by(1)
    end

    it 'Creates a participation that does not notify the assigner' do
      participation = ParticipationFactory.create(full_params)
      expect(participation.notify_requester).to eq(false)
    end

    it 'Creates a participation that notifies the assigner if is the same' do
      participation = ParticipationFactory.create(same_params)
      expect(participation.notify_requester).to eq(true)
    end

    it 'Does not email the assignee if is the same as the assigner' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(same_params)
    end
  end
end
