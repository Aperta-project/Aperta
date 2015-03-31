module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, inverse_of: :task, foreign_key: :task_id
  end

  # Public: after transition hook for custom task behavior upon transitioning to "invited" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Use this method to send an invitation email a user can accept/reject
  #
  # Returns true, is a noop if unimplemented
  def invitation_invited(_invitation)
    true
  end

  # Public: after transition hook for custom task behavior upon transitioning to "accepted" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Implement this hook to create the association between the accepting user and the paper
  #
  # Returns true, is a noop if unimplemented
  def invitation_accepted(_invitation)
    true
  end

  # Public: after transition hook for custom task behavior upon transitioning to "rejected" state
  #
  # _invitation - the invitation
  #
  # Examples
  #
  #   Implement this hook to notify the next person in the queue of people to invite
  #
  # Returns true, is a noop if unimplemented
  def invitation_rejected(_invitation)
    true
  end
end
