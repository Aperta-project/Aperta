require "rails_helper"

describe EventStream::Notifiable do

  # a model with an event_stream_notifier included
  let(:model) { FactoryGirl.create(:paper) }

  describe "#event_payload" do
    let(:payload) do
      model.event_payload
    end

    it "contains the serialized model" do
      expect(payload[:record]).to eq(model)
    end

    context "when created" do
      it "sends the 'created' action" do
        expect(payload[:action]).to eq("created")
      end
    end

    context "when updated" do
      let(:payload) do
        paper = Paper.find(model.id)
        paper.touch
        paper.event_payload
      end

      it "sends the 'updated' action" do
        expect(payload[:action]).to eq("updated")
      end
    end

    context "when destroyed" do
      let(:payload) do
        paper = Paper.find(model.id)
        paper.destroy
        paper.event_payload
      end

      it "sends the 'destroyed' action" do
        expect(payload[:action]).to eq("destroyed")
      end
    end
  end

end
