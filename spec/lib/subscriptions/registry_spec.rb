require 'rails_helper'

describe Subscriptions::Registry do
  module TestSubscribers
    class Base
      def self.called
        @called ||= []
      end

      def self.call(*args)
        called << args
      end

      def self.reset
        called.clear
      end
    end

    class Jerry < Base
    end
    class AaronsTwitter < Base
    end
    class LeakyWindow < Base
    end
  end

  before do
    stub_const('Subscriptions::APPLICATION_EVENT_NAMESPACE', 'app_namespace')
    TestSubscribers::Jerry.reset
    TestSubscribers::AaronsTwitter.reset
    TestSubscribers::LeakyWindow.reset
  end

  after do
    subject.unsubscribe_all
  end

  describe "initialize" do
    it "begins empty" do
      expect(subject.count).to eq(0)
    end
  end

  describe "add" do
    it "saves a new event" do
      subject.add('mail:arrived', TestSubscribers::Jerry)
      subject.add('coffee:brewed', TestSubscribers::Jerry)
      expect(subject.count).to eq(2)
    end

    it "merges with an existing event" do
      subject.add('mail:arrived', TestSubscribers::Jerry)
      subject.add('mail:arrived', TestSubscribers::AaronsTwitter)
      expect(subject.count).to eq(1)
      expect(subject.subscribers_for('mail:arrived')).to have(2).subscribers
    end

    it "subscribes to the event" do
      subject.add('mail:arrived', TestSubscribers::Jerry, TestSubscribers::AaronsTwitter)

      ActiveSupport::Notifications.instrument("app_namespace:mail:arrived")
      expect(TestSubscribers::Jerry.called.length).to eq 1
      expect(TestSubscribers::AaronsTwitter.called.length).to eq 1
    end

    it "rejects duplicate subscribers" do
      expect {
        subject.add('mail:arrived', TestSubscribers::Jerry)
        subject.add('mail:arrived', TestSubscribers::Jerry)
      }.to raise_error(Subscriptions::DuplicateSubscribersRegistrationError)
    end
  end

  describe "subscribers_for" do
    before do
      subject.add('mail:arrived', TestSubscribers::Jerry, TestSubscribers::AaronsTwitter)
      subject.add('coffee:brewed', TestSubscribers::Jerry)
      subject.add('thunderstorm:arrived', TestSubscribers::LeakyWindow)
    end

    it "filters registered subscribers by event name" do
      expect(subject.subscribers_for('mail:arrived')).to contain_exactly(TestSubscribers::Jerry, TestSubscribers::AaronsTwitter)
      expect(subject.subscribers_for('coffee:brewed')).to contain_exactly(TestSubscribers::Jerry)
      expect(subject.subscribers_for('thunderstorm:arrived')).to contain_exactly(TestSubscribers::LeakyWindow)
    end

    it "allows filtering by regex" do
      expect(subject.subscribers_for(/.*:arrived/)).to contain_exactly(TestSubscribers::Jerry, TestSubscribers::AaronsTwitter, TestSubscribers::LeakyWindow)
    end
  end

  describe "unsubscribe_all" do
    before do
      subject.add('coffee:brewed', TestSubscribers::Jerry)
      subject.add('thunderstorm:arrived', TestSubscribers::LeakyWindow)
    end

    before do
      expect {
        ActiveSupport::Notifications.instrument("app_namespace:coffee:brewed")
      }.to change { TestSubscribers::Jerry.called.count }

      expect {
        ActiveSupport::Notifications.instrument("app_namespace:thunderstorm:arrived")
      }.to change { TestSubscribers::LeakyWindow.called.count }
    end

    it "unsubscribes all subscribers" do
      subject.unsubscribe_all

      expect {
        ActiveSupport::Notifications.instrument("app_namespace:coffee:brewed")
      }.to_not change { TestSubscribers::Jerry.called.count }

      expect {
        ActiveSupport::Notifications.instrument("app_namespace:thunderstorm:arrived")
      }.to_not change { TestSubscribers::LeakyWindow.called.count }
    end
  end

end
