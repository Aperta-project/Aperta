# Queues are used to hold groups of invitations that can either be
# sent individually or at a later time.
class InviteQueue < ActiveRecord::Base
  belongs_to :task
  belongs_to :primary, class_name: 'Invitation'
  belongs_to :decision
  has_many :invitations

  def grouped_alternates
    invitations.where.not(primary: nil)
  end
  def ungrouped_primaries
    invitations.select(&:ungrouped_primary?)
  end

  def add_invite(invite)
    # acts_as_list always puts new items at the bottom of the list by default,
    # so we don't need to do anything further.
    invite.update(invite_queue: self)
  end

  def valid_positions_for_invite(invite)
    return [] if invite.has_alternates? || !invite.pending?
    valid_invites = if invite.is_alternate?
                      invite.primary.alternates
                    else
                      invitations.reload.select(&:ungrouped_primary?)
                    end

    valid_invites
      .select(&:pending?)
      .reject { |i| i.id == invite.id }
      .map(&:position)
  end

  # This method is never intended to be called on an unpersisted invitation
  def move_invite_to_position(invite, pos)
    if valid_positions_for_invite(invite).include? pos
      invite.insert_at(pos)
    else
      invite.errors.add(:position, "is not valid.")
      raise ActiveRecord::RecordInvalid, invite
    end
  end

  def create_primary_group(invite:, primary:)
    # find the max position of any alternate, and put the new primary below that
    last_alternate = grouped_alternates.maximum(:position)
    invite.update(primary: primary)

    # it seems we need to reload both records to get acts_as_list to behave well
    invite.reload
    primary.reload
    if last_alternate
      primary.insert_at(last_alternate + 1)
      invite.insert_at(last_alternate + 2)
    else
      primary.move_to_top
      invite.insert_at(2)
    end
  end

  def assign_primary(invite:, primary:)
    raise_primary_error(invite, "alternates must be ungrouped before being reassigned") if invite.is_alternate?
    raise_primary_error(invite, "a primary with alternates must be ungrouped before being reassigned") if invite.has_alternates?
    raise_primary_error(invite, "an alternate cannot be assigned as a primary") if primary.is_alternate?
    raise_primary_error(invite, "sent invitations cannot have their primary assignment changed") if !invite.pending?

    if primary.has_alternates?
      last_alternate = primary.alternates.maximum(:position)
      invite.update(primary: primary)
      invite.reload

      invite.insert_at(last_alternate + 1)
    else
      create_primary_group(invite: invite, primary: primary)
    end
  end

  def unassign_primary(invite)
    raise_primary_error(invite, "invite already has no primary") if invite.primary.blank?
    raise_primary_error(invite, "a primary with alternates is not valid for unassigning") if invite.has_alternates?
    raise_primary_error(invite, "sent invitations cannot have their primary assignment changed") if !invite.pending?

    existing_primary = invite.primary
    invite.update(primary: nil)

    unless invite.alternates.exists? #if the primary has no more alternates it's ungrouped
      existing_primary.move_to_bottom
    end
    invite.move_to_bottom
  end

  def remove_invite(invite)

  end

  def send_invite(invite)

  end

  private

  def raise_primary_error(invite, msg)
    invite.errors.add(:primary, msg)
    raise ActiveRecord::RecordInvalid, invite
  end
end
