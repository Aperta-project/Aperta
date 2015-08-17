require "rails_helper"

describe EventStream::Notifiable do

  before do
    RequestStore.store[:requester_pusher_socket_id] = "test_socket"
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
