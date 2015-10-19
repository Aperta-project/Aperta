require 'rails_helper'

describe FlashMessageSubscriber do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:the_user) { create(:user) }

  it 'should fail unless user method defined' do
    klass = Class.new(FlashMessageSubscriber) do
      def message
      end

      def message_type
        'foo'
      end
    end

    expect { klass.call('foo', {}) }.to raise_exception(NotImplementedError)
  end

  it 'should fail unless message method defined' do
    klass = Class.new(FlashMessageSubscriber) do
      def user
        FactoryGirl.create(:user)
      end

      def message_type
        'foo'
      end
    end

    expect { klass.call('foo', {}) }.to raise_exception(NotImplementedError)
  end

  it 'should fail unless message_type method defined' do
    klass = Class.new(FlashMessageSubscriber) do
      def user
        FactoryGirl.create(:user)
      end

      def message
      end
    end

    expect { klass.call('foo', {}) }.to raise_exception(NotImplementedError)
  end

  it 'should not push data if message_type returns nil' do
    klass = Class.new(FlashMessageSubscriber) do
      def user
        @event_data[:user]
      end

      def message_type
        nil
      end

      def message
        'You have an error!'
      end
    end
    expect(pusher_channel).to_not receive_push(serialize: [:messageType, :message], down: 'user', on: 'flashMessage')
    klass.call('message-type', user: the_user)
  end

  it 'should push data' do
    klass = Class.new(FlashMessageSubscriber) do
      def user
        @event_data[:user]
      end

      def message_type
        'error'
      end

      def message
        'You have an error!'
      end
    end

    expect(pusher_channel).to receive_push(serialize: [:messageType, :message], down: 'user', on: 'flashMessage')
    klass.call('message-type', user: the_user)
  end
end
