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

module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, inverse_of: :task, foreign_key: :task_id, dependent: :destroy
    has_one :invitation_queue, inverse_of: :task, foreign_key: :task_id, dependent: :destroy
  end

  def active_invitation_queue
    # noop - To be implemented by other tasks whether invitation queues
    #        are tied to decision or task
  end

  # Public: after transition hook for custom task behavior upon
  #         transitioning to "invited" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Use this method to send an invitation email a user can accept/decline
  #
  # Returns true, is a noop if unimplemented
  def invitation_invited(_invitation)
    true
  end

  # Public: after transition hook for custom task behavior upon
  #         transitioning to "accepted" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Implement this hook to create the association between the accepting
  #   user and the paper
  #
  # Returns true, is a noop if unimplemented
  def invitation_accepted(_invitation)
    true
  end

  # Public: after transition hook for custom task behavior upon being deleted
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Sending an email to notify the user their invitation is no longer valid
  #
  # Returns true, is a noop if unimplemented
  def invitation_rescinded(_invitation)
    true
  end

  # Public: after transition hook for custom task behavior upon
  #         transitioning to "declined" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Implement this hook to notify the next person in the queue of
  #   people to invite
  #
  # Returns true, is a noop if unimplemented
  def invitation_declined(_invitation)
    true
  end

  # Public: guard for custom task behavior before transitioning
  #         to "invited" state
  #
  # _invitation - the invitation
  #
  # Returns true, is a noop if unimplemented
  def invite_allowed?(_invitation)
    true
  end

  # Public: guard for custom task behavior before transitioning
  #         to "accepted" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Implement this guard to to prevent an invitation from being accepted for
  #   a paper that already has an accepted invitation
  #
  # Returns true, is a noop if unimplemented
  def accept_allowed?(_invitation)
    true
  end

  # Public: guard for custom task behavior before transitioning
  #         to "declined" state
  #
  # _invitation - the invitation
  #
  # Returns true, is a noop if unimplemented
  def decline_allowed?(_invitation)
    true
  end

  def invitee_role
    raise NotImplementedError,
         'Please implement #invitee_role in the task model'
  end
end
