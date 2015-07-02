require 'rails_helper'

describe ApplicationController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  controller(ApplicationController) do
    def index
      ActiveSupport::Notifications.instrument "test.event", this: :data do
        # do nothing, just trigger event
      end
      # do nothing, successfully
      render nothing: true
    end
  end

  describe '#pusher_fail' do
    ActiveSupport::Notifications.subscribe "test.event" do |_, _, _, _, _|
      # This will raise an error
      TahiPusher::Channel.new(channel_name: 'foobar').push(event_name: 'foo', payload: 'bar')
    end

    it 'should succeed and call pusher' do
      expect(Pusher).to receive(:trigger)
      get :index
      expect(response).to be_success
    end

    it 'should succeed even when pusher errors' do
      expect(Pusher).to receive(:trigger).and_raise(Pusher::Error)
      get :index
      expect(response).to be_success
    end
  end
end
