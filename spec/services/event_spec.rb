require 'rails_helper'

describe Event do
  let(:action_data) { { user: user, task: task, paper: task.paper } }
  let(:action) { double(klass) }
  let(:klass) { Class.new(BehaviorAction) }
  let(:user) { create(:user) }
  let!(:task) { FactoryGirl.create(:task, :with_card, title: Faker::Lorem.sentence) }

  subject { Event.broadcast('paper_submitted', **action_data) }

  describe '#broadcast' do
    it 'should append to the ActivityFeed' do
      expect(Activity).to receive(:create).with(
        feed_name: 'forensic',
        subject: task,
        activity_key: 'paper_submitted',
        user: user
      )
      subject
    end

    context 'when an behavior is defined' do
      let(:behavior_params) { { "string_param" => 'hello', "boolean_param" => false } }

      let!(:event_behavior) do
        create(
          :event_behavior,
          { action: 'send_email',
            event_name: 'paper_submitted' }
            .merge(behavior_params)
        )
      end

      it 'the behaviors action should be called' do
        expect(BehaviorAction).to receive(:find).with('send_email').and_return(klass)
        expect(klass).to receive(:new).and_return(action)
        expect(action).to receive(:call).with(behavior_params, action_data)
        subject
      end
    end
  end
end
