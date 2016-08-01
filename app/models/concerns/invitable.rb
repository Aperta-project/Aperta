module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, inverse_of: :task, foreign_key: :task_id, dependent: :destroy
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
    fail NotImplementedError,
         'Please implement #invitee_role in the task model'
  end
end
