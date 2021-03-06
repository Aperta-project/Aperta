# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
