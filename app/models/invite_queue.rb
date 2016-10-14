# Queues are used to hold groups of invitations that can either be
# sent individually or at a later time.
class InviteQueue < ActiveRecord::Base
  belongs_to :task
  belongs_to :primary, class_name: 'Invitation'
  belongs_to :decision
  has_many :invitations

  def add_invite(invite)
    # acts_as_list always puts new items at the bottom of the list by default,
    # so we don't need to do anything further.
    invite.update(invite_queue: self)
  end

  def valid_positions_for_invite(invite)
    return [] if invite.has_alternates?
    return invite.primary.alternates.pluck(:position) if invite.is_alternate?
    valid_positions = []
    invite.invite_queue.invitations.each do |invitation|
      if invitation.main_queue? && invitation.pending?
        valid_positions << invitation.position
      end
    end
    return valid_positions
  end

  def move_invite_to_position(invite, pos)
    if valid_positions_for_invite(invite).include? pos
      invite.insert_at(pos)
    else
      invite.errors.add(:position, "is not valid.")
      raise ActiveRecord::RecordInvalid, invite
    end
  end

  def assign_primary(invite:, primary:)
    invite.primary = primary
    invite.save
    primary.move_to_top
    invite.insert_at(2)
  end

  def unassign_primary(invite)

  end

  def remove_invite(invite)

  end

  def ungrouped_primaries
    invitations.ungrouped
  end
end
