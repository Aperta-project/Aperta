require 'rails_helper'

describe Subscriptions do
  module TestSubscribers
    class FireRescueTeam; end
    class PressHelicopter; end
    class NeilDegrassTyson; end
  end

  before { Subscriptions.clear_all_subscriptions! }

  describe "configure" do
    before { stub_const('Subscriptions::APPLICATION_EVENT_NAMESPACE', 'app_namespace') }

    it "subscribers are actually subscribed via ActiveSupport::Notifications" do
      expect(ActiveSupport::Notifications).to receive(:subscribe) do |event_name|
        expect(event_name).to match('app_namespace:big:explosion')
      end

      Subscriptions.configure do
        add "big:explosion", TestSubscribers::FireRescueTeam
      end
    end

    it "allows multiple subscribers" do
      Subscriptions.configure do
        add "big:explosion", TestSubscribers::FireRescueTeam, TestSubscribers::NeilDegrassTyson
      end

      first_responders = [
        TestSubscribers::FireRescueTeam,
        TestSubscribers::NeilDegrassTyson
      ]
      expect(Subscriptions.subscribers_for('big:explosion')).to contain_exactly(*first_responders)
    end

    it "allows registering events from multiple places" do
      Subscriptions.configure do
        add "big:explosion", TestSubscribers::FireRescueTeam
      end

      Subscriptions.configure do
        add "big:explosion", TestSubscribers::PressHelicopter
      end

      first_responders = [
        TestSubscribers::FireRescueTeam,
        TestSubscribers::PressHelicopter
      ]
      expect(Subscriptions.subscribers_for('big:explosion')).to contain_exactly(*first_responders)
    end

    it "rejects duplicate subscribers for the same event" do
      expect {
        Subscriptions.configure do
          add "big:explosion", TestSubscribers::FireRescueTeam
          add "big:explosion", TestSubscribers::FireRescueTeam
        end
      }.to raise_error(Subscriptions::DuplicateSubscribersRegistrationError)
    end

  end

  describe "pretty_print" do

    it "includes events followed by the corresponding subscriber names" do
      Subscriptions.configure do
        add "big:explosion", TestSubscribers::FireRescueTeam
        add "big:explosion", TestSubscribers::PressHelicopter
      end
      console = StringIO.new
      Subscriptions.pretty_print(console)
      expect(console.string).to match(/big:explosion.*FireRescue.*PressHelicopter/)
    end

  end

end

