require "rails_helper"

describe CorrespondenceSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:correspondence) { FactoryGirl.create :correspondence }

  let(:object_for_serializer) { correspondence }

  describe 'after a correespondence is added' do
    before { Activity.correspondence_created! correspondence, user: user }

    it 'adds correspondence activities' do
      serialized_correspondence = serializer.as_json[:correspondence]
      expect(serialized_correspondence).to have_key(:activities)
    end

    it 'shows the add activity for a paper' do
      serialized_activities = serializer.as_json.dig(:correspondence, :activities)
      expect(serialized_activities.count).to be 1 # a correspondence can only be created once
    end

    it 'prints the "Added" message' do
      added_message = serializer.as_json.dig(:correspondence, :activities).first.first
      expect(added_message).to match("correspondence.created")
    end
  end
end
