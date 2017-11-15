require 'rails_helper'

describe Event do
  let(:action_data) { { user: user, task: task, paper: task.paper } }
  let(:action) { double(klass) }
  let(:klass) { Class.new(BehaviorAction) }
  let(:user) { create(:user) }
  let(:task) { FactoryGirl.create(:task, :with_card, title: Faker::Lorem.sentence, paper: paper) }
  let(:paper) { create(:paper) }
  subject { Event.trigger(:good_event, **action_data) }

  before(:each) do
    Event.register(:good_event)
  end

  after(:each) do
    Event.deregister(:good_event)
  end

  describe '#trigger' do
    it 'should error if the event is not registered' do
      expect { Event.trigger(:bad_event, paper: paper) }.to raise_error(ArgumentError, /not registered/)
    end

    it 'should error if the paper is nil' do
      expect { Event.trigger(:good_event, paper: nil) }.to raise_error(ArgumentError, /paper is required/)
    end

    it 'should error if the paper is nil' do
      expect { Event.trigger(:good_event, paper: nil) }.to raise_error(ArgumentError, /paper is required/)
    end

    it 'should append to the ActivityFeed' do
      expect(Activity).to receive(:create).with(
        feed_name: 'forensic',
        subject: task,
        activity_key: :good_event,
        user: user,
        message: nil
      )
      subject
    end

    context 'broadcasting' do
      let!(:need_to_preload_user) { [user] }

      it 'should broadcast to the pub/sub system' do
        expect(Notifier).to receive(:notify).with(
          event: :good_event,
          data: {
            paper: paper,
            task: task
          }
        )
        subject
      end
    end

    context 'when an behavior is defined' do
      let!(:send_email_behavior) do
        create(
          :behavior,
          event_name: :good_event
        )
      end
      let(:paper) { FactoryGirl.create(:paper) }
      let(:user) { FactoryGirl.create(:user) }

      it 'should call the call method with action parameters' do
        expect(Behavior).to receive(:where).with(event_name: :good_event).and_return([send_email_behavior])
        expect(send_email_behavior).to receive(:call).with(
          user: user, paper: paper, task: nil
        )
        Event.trigger(:good_event, paper: paper, user: user)
      end
    end
  end
end
