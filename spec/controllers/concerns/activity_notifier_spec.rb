require "rails_helper"

describe ActivityNotifier do

  before do
    class FakeModel
      include ActivityNotifier
    end
  end

  let(:model) { FakeModel.new }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  describe "#broadcast" do
    it "creates an activity" do
      expect {
        model.broadcast(event_name: "paper::exploded", target: paper, scope: paper, actor: user, region_name: "paper")
      }.to change { Activity.count }.by(1)
    end

    it "broadcasts the activity" do
      expect(TahiNotifier).to receive(:notify)
      model.broadcast(event_name: "paper::exploded", target: paper, scope: paper, actor: user, region_name: "paper")
    end
  end
end
