require 'rails_helper'
require 'subscriptions/console_formatter'

describe Subscriptions do
  module TestSubscribers
    class FireRescueTeam; end
    class PressHelicopter; end
    class NeilDegrassTyson; end
  end

  before(:each) do
    @config = Subscriptions.current_configuration
    Subscriptions.reset
  end

  after(:each) do
    Subscriptions.restore_configuration(@config)
  end

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

  describe 'reset' do
    it 'unsubscribes all subscribers' do
      Subscriptions.configure do
        add 'big:explosion', TestSubscribers::FireRescueTeam
      end
      expect(Subscriptions.subscribers_for('big:explosion').length).to_not be 0
      Subscriptions.reset
      expect(Subscriptions.subscribers_for('big:explosion').length).to eq 0
    end

    it 'clears out previous configure blocks so they do not reload' do
      c = 0
      Subscriptions.configure { c += 1 }
      expect(c).to eq 1

      Subscriptions.reset

      # reload sould not change c since the configure block shouldn't re-run
      Subscriptions.reload
      expect(c).to eq 1
    end
  end

  describe 'unsubscribe_all' do
    before do
      Subscriptions.configure do
        add 'big:explosion', TestSubscribers::FireRescueTeam
      end
      expect(Subscriptions.subscribers_for('big:explosion').length).to_not be 0
    end

    it 'unsubscribes all subscribers' do
      Subscriptions.unsubscribe_all
      expect(Subscriptions.subscribers_for('big:explosion').length).to eq 0
    end
  end

  describe 'reload' do
    it 'reloads any configuration blocks it received' do
      c = 0
      Subscriptions.configure { c += 1 }
      expect(c).to eq(1)
      Subscriptions.reload
      expect(c).to eq(2)
    end
  end
end
