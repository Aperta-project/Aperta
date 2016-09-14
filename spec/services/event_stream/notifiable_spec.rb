require "rails_helper"

describe EventStream::Notifiable do

  before do
    RequestStore.store[:requester_pusher_socket_id] = "test_socket"
    RequestStore.store[:requester_current_user_id] = 1
  end

  describe "#notify" do
    # a model with an event_stream_notifier included
    let!(:model) { FactoryGirl.build(:comment) }

    before do
      allow(Notifier).to receive(:notify)
    end

    it "sends a Notifier notification when the model is saved" do
      expect(Notifier).to receive(:notify).with(
        event: "comment:created", data: {
          action: "created",
          record: model,
          requester_socket_id: "test_socket",
          current_user_id: 1
        }
      )
      model.save!
    end

    it "can send a notification with a custom event action and payload" do
      expect(Notifier).to receive(:notify).with(
        event: "comment:custom-event",
        data: { custom: "data" }
      )
      model.notify action: "custom-event", payload: { custom: "data" }
    end

    context "when notifications are disabled" do
      it "does not send notifications" do
        expect(Notifier).to_not receive(:notify)
        model.notifications_enabled = false
        model.save!
      end

      it "does not send custom notifications" do
        expect(Notifier).to_not receive(:notify)
        model.notifications_enabled = false
        model.notify action: "custom-event", payload: { custom: "data" }
      end
    end
  end

  describe "#event_payload without requester notification" do
    # a model with an event_stream_notifier included
    let(:model) { FactoryGirl.create(:comment) }

    let(:payload) do
      model.event_payload
    end

    it "contains the serialized model" do
      expect(payload[:record]).to eq(model)
    end

    it "contains an excluded requester_socket_id" do
      expect(payload[:requester_socket_id]).to eq("test_socket")
    end

    context "when created" do
      it "sends the 'created' action" do
        expect(payload[:action]).to eq("created")
      end
    end

    context "when updated" do
      let(:payload) do
        comment = Comment.find(model.id)
        comment.touch
        comment.event_payload
      end

      it "sends the 'updated' action" do
        expect(payload[:action]).to eq("updated")
      end
    end

    context "when destroyed" do
      let(:payload) do
        comment = Comment.find(model.id)
        comment.destroy
        comment.event_payload
      end

      it "sends the 'destroyed' action" do
        expect(payload[:action]).to eq("destroyed")
      end
    end
  end

  describe "#event_payload with requester notification" do
    # a model with an event_stream_notifier included
    let(:model) { FactoryGirl.create(:comment, notify_requester: true) }

    let(:payload) do
      model.event_payload
    end

    it "does not contain and excluded requester_socket_id" do
      expect(payload[:requester_socket_id]).to be_nil
    end
  end
end
