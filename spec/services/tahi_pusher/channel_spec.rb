require "rails_helper"

describe TahiPusher::Channel do

  let(:channel_name) { "private-paper@4" }
  let(:channel) { TahiPusher::Channel.new(channel_name: channel_name) }

  describe "#authenticate" do
    let(:socket_id) { "999" }

    it "with the correct channel" do
      expect(Pusher).to receive(:[]).with(channel_name).and_call_original
      channel.authenticate(socket_id: socket_id)
    end

    it "with the correct socket" do
      expect_any_instance_of(Pusher::Channel).to receive(:authenticate).with(socket_id)
      channel.authenticate(socket_id: socket_id)
    end
  end

  describe "#push" do
    let(:event_name) { "created" }
    let(:payload) { { somejson: true } }

    it "sends payload to pusher channel" do
      expect(Pusher).to receive(:trigger).with(channel_name, event_name, payload)
      channel.push(event_name: event_name, payload: payload)
    end
  end

  describe "authorized?" do
    let(:user) { double(:user, id: 1) }

    context "when target is not active record object" do
      let(:channel) { TahiPusher::Channel.new(channel_name: "system") }

      it "returns true" do
        expect(channel.authorized?(user: user)).to eq(true)
      end
    end

    context "when target is active record object" do
      let(:channel) { TahiPusher::Channel.new(channel_name: "private-paper@4") }

      context "when the target exists" do
        context "when user has access to the target" do
          it "returns true" do
            allow(channel).to receive(:authorized_users).and_return([user])
            expect(channel.authorized?(user: user)).to eq(true)
          end
        end

        context "when user does not have access to the target" do
          it "returns false" do
            allow(channel).to receive(:authorized_users).and_return([])
            expect(channel.authorized?(user: user)).to eq(false)
          end
        end
      end

      context "when the target does not exist" do
        it "returns false" do
          allow(channel).to receive(:authorized_users).and_raise(ActiveRecord::RecordNotFound)
          expect(channel.authorized?(user: user)).to eq(false)
        end
      end
    end
  end
end

