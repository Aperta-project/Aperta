require "rails_helper"

describe EventStream::Broadcaster do

  let(:model) { FactoryGirl.create(:paper) }
  let(:broadcaster) { EventStream::Broadcaster.new(model) }
  let(:channel) { double(:channel, push: nil) }

  describe "#post" do
    context "pusher is disabled" do
      before do
        allow(TahiPusher::Config).to receive(:enabled?).and_return(false)
      end

      it "does nothing" do
        expect(TahiPusher::Channel).to_not receive(:new)
        broadcaster.post(action: "destroyed", channel_scope: model)
      end
    end

    context "destroyed action", sidekiq: :inline! do
      it "sends to the system channel" do
        expect(TahiPusher::Channel).to receive(:new).with(channel_name: "system").and_return(channel)
        broadcaster.post(action: "destroyed", channel_scope: model)
      end

      it "sends 'destroyed' as the event_name" do
        allow(TahiPusher::Channel).to receive(:new).and_return(channel)
        expect(channel).to receive(:push).with(hash_including(event_name: "destroyed"))
        broadcaster.post(action: "destroyed", channel_scope: model)
      end

      it "sends the destroyed payload" do
        allow(TahiPusher::Channel).to receive(:new).and_return(channel)
        expect(channel).to receive(:push).with(hash_including(payload: model.destroyed_payload))
        broadcaster.post(action: "destroyed", channel_scope: model)
      end
    end

    context "created or updated action", sidekiq: :inline! do
      it "sends to the paper channel" do
        expect(TahiPusher::Channel).to receive(:new).with(channel_name: "private-paper@#{model.id}").and_return(channel)
        broadcaster.post(action: "updated", channel_scope: model)
      end

      it "sends the correct event_name" do
        allow(TahiPusher::Channel).to receive(:new).and_return(channel)
        expect(channel).to receive(:push).with(hash_including(event_name: "updated"))
        broadcaster.post(action: "updated", channel_scope: model)
      end

      it "sends the payload" do
        allow(TahiPusher::Channel).to receive(:new).and_return(channel)
        expect(channel).to receive(:push).with(hash_including(payload: model.payload))
        broadcaster.post(action: "updated", channel_scope: model)
      end
    end
  end


end
