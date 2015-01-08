require "rails_helper"

describe EventStreamNotifier do

  # a model with an event_stream_notifier included
  let(:model) { FactoryGirl.build(:paper, id: 4) }

  describe "#event_stream_payload" do
    let(:payload) { model.event_stream_payload }

    it "contains the serialized model" do
      expect(payload[:record]).to eq(model)
    end

  end

end
