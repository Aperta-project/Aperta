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

describe InvitationIndexSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it 'serializes successfully' do
    expect(deserialized_content).to match(hash_including(:invitation))

    expect(invitation_content).to match hash_including(
      id: invitation.id,
      state: invitation.state,
      title: invitation.paper.title,
      abstract: invitation.paper.abstract,
      email: invitation.email,
      information: invitation.information,
      invitee_id: invitation.invitee_id,
      invitee_role: invitation.invitee_role,
      task: { id: invitation.task.id, type: invitation.task.type.underscore.dasherize }
    )

    expect(invitation_content.fetch(:created_at)).to be
    expect(invitation_content.fetch(:updated_at)).to be
  end
end
