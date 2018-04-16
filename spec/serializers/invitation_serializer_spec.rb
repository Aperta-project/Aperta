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

describe InvitationSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let!(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }
  let(:object_for_serializer) { invitation }

  let(:invitation_content) { deserialized_content.fetch(:invitation) }

  it 'serializes successfully' do
    expect(deserialized_content).to match(hash_including(:invitation))

    expect(invitation_content).to match hash_including(
      decline_reason: invitation.decline_reason,
      email: invitation.email,
      id: invitation.id,
      invitee_role: invitation.invitee_role,
      reviewer_suggestions: invitation.reviewer_suggestions,
      state: invitation.state
    )

    expect(invitation_content.fetch(:created_at)).to be
    expect(invitation_content.fetch(:updated_at)).to be
  end

  context 'without an invitee' do
    subject(:invitation) { FactoryGirl.create :invitation, task: task, invitee: nil, actor: nil }

    it 'serializes successfully' do
      expect(deserialized_content).to match(hash_including(users: []))
    end
  end

end
