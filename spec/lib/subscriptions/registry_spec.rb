require 'rails_helper'

describe Subscriptions::Registry do
  module TestSubscribers
    class Jerry
    end
    class AaronsTwitter
    end
    class LeakyWindow
    end
  end

  describe "initialize" do

    it "begins empty" do
      expect(subject.count).to eq(0)
    end

  end

  describe "add" do
    before { stub_const('Subscriptions::APPLICATION_EVENT_NAMESPACE', 'app_namespace') }

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
      expect(ActiveSupport::Notifications).to receive(:subscribe).twice do |event_name|
        expect(event_name).to match('app_namespace:mail:arrived')
      end
      subject.add('mail:arrived', TestSubscribers::Jerry, TestSubscribers::AaronsTwitter)
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

end
