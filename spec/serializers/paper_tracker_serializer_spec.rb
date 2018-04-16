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

require 'rails_helper'
require 'support/authorization_spec_helper'

describe PaperTrackerSerializer, serializer_test: true do
  include AuthorizationSpecHelper

  let(:paper) { FactoryGirl.build_stubbed :paper }
  let(:object_for_serializer) { paper }
  let(:paper_content) { deserialized_content.fetch(:paper_tracker) }

  describe 'related_users' do
    let!(:creator) { FactoryGirl.build_stubbed :user }
    let!(:collaborator) { FactoryGirl.build_stubbed :user }
    let!(:cover_editor) { FactoryGirl.build_stubbed :user }
    let!(:handling_editor) { FactoryGirl.build_stubbed :user }
    let(:roles) { paper_content[:related_users] }

    before do
      allow(paper).to receive(:cover_editors).and_return([cover_editor])
      allow(paper).to receive(:handling_editors).and_return([handling_editor])

      allow(paper).to receive(:participants_by_role).and_return(
        'Creator' => [creator],
        'Collaborator' => [collaborator],
        'Cover Editor' => [cover_editor],
        'Handling Editor' => [handling_editor]
      )
    end

    it 'includes creator users' do
      users = roles.find { |r| r[:name] == 'Creator' }[:users]
      expect(users.first[:id]).to eq(creator.id)
    end

    it 'includes collaborator users' do
      users = roles.find { |r| r[:name] == 'Collaborator' }[:users]
      expect(users.last[:id]).to eq(collaborator.id)
    end

    it 'includes cover editor users' do
      users = roles.find { |r| r[:name] == 'Cover Editor' }[:users]
      expect(users.last[:id]).to eq(cover_editor.id)
    end

    it 'includes handling editor users' do
      users = roles.find { |r| r[:name] == 'Handling Editor' }[:users]
      expect(users.last[:id]).to eq(handling_editor.id)
    end
  end

  it 'serializes paper data' do
    expect(paper_content).to match hash_including(
      cover_editors: paper.cover_editors,
      first_submitted_at: paper.first_submitted_at,
      handling_editors: paper.handling_editors,
      paper_type: paper.paper_type,
      submitted_at: paper.submitted_at
    )
  end
end
