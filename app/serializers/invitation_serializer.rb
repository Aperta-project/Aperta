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

class InvitationSerializer < AuthzSerializer
  attributes :id,
             :body,
             :created_at,
             :decline_reason,
             :email,
             :invitee_role,
             :reviewer_suggestions,
             :state,
             :updated_at,
             :invited_at,
             :declined_at,
             :accepted_at,
             :rescinded_at,
             :position,
             :decision_id,
             :valid_new_positions_for_invitation,
             :due_in

  has_one :invitee, serializer: FilteredUserSerializer, embed: :id, root: :users, include: true
  has_one :actor, serializer: FilteredUserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true
  has_many :attachments, embed: :id, polymorphic: true, include: true
  has_one :primary, embed: :id
  has_many :alternates, embed: :id
  has_one :reviewer_report, embed: :id, include: false

  def valid_new_positions_for_invitation
    object.invitation_queue.valid_new_positions_for_invitation(object)
  end

  def reviewer_report
    ReviewerReport.for_invitation(object)
  end
end
