require 'rails_helper'

describe Notifier do

  describe "notify" do
    let(:event_name) { 'big:explosion' }
    let(:data) { { radius: 100 } }
    let(:prefixed) { "app_namespace:big:explosion" }

    before { stub_const('Subscriptions::APPLICATION_EVENT_NAMESPACE', 'app_namespace') }

    it "publishes the event with the prefixed event name" do
      expect(ActiveSupport::Notifications).to receive(:instrument).with(prefixed, data)
      Notifier.notify(event: event_name, data: data)
    end

  end

end
