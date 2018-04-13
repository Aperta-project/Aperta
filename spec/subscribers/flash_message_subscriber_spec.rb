# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
    expect(pusher_channel).to_not receive_push(payload: hash_including(:messageType, :message), down: 'user', on: 'flashMessage')
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

    expect(pusher_channel).to receive_push(payload: hash_including(:messageType, :message), down: 'user', on: 'flashMessage')
    klass.call('message-type', user: the_user)
  end
end
