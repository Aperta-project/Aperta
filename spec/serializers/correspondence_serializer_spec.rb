require "rails_helper"

describe CorrespondenceSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:correspondence) { FactoryGirl.create :correspondence }
  let(:external_correspondence) { FactoryGirl.create :correspondence, :as_external }

  let(:object_for_serializer) { correspondence }

  describe 'after a correspondence is added' do
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
      added_message = serializer.as_json.dig(:correspondence, :activities).first[:key]
      expect(added_message).to match("correspondence.created")
    end
  end

  describe 'after a correspondence is edited' do
    before { Activity.correspondence_edited! correspondence, user: user }

    it 'adds correspondence activities' do
      serialized_correspondence = serializer.as_json[:correspondence]
      expect(serialized_correspondence).to have_key(:activities)
    end

    it 'prints the "Added" message' do
      added_message = serializer.as_json.dig(:correspondence, :activities).first[:key]
      expect(added_message).to match("correspondence.edited")
    end
  end

  describe 'after a manual correspondence is deleted' do
    let(:object_for_serializer) { external_correspondence }
    before do
      external_correspondence.update!(status: 'deleted', additional_context: { delete_reason: 'test' })
      Activity.correspondence_deleted! external_correspondence, user: user
    end

    # As a security concern, we are purposefully restricting the serialized fields of a soft-deleted
    # correspondence record, so that the user can't access it in any way, in case the record was
    # deleted because it exposed sensitive information, was libelous, etc.
    it 'strips detail fields of correspondence record' do
      serialized_correspondence = serializer.as_json[:correspondence]
      expect(serialized_correspondence).to have_key(:activities)
      expect(serialized_correspondence).to_not have_key(:subject)
      expect(serialized_correspondence).to_not have_key(:body)
      expect(serialized_correspondence).to_not have_key(:sender)
      expect(serialized_correspondence).to_not have_key(:description)
    end
  end
end
