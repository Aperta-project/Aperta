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
