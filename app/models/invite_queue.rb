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
    invite.move_to_bottom
  end

  def valid_new_positions_for_invite(invite)
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

  def move_invite_to_position(invite, pos)
    raise_position_error(invite, "unpersisted invitation called") unless invite.persisted?

    if valid_new_positions_for_invite(invite).include? pos
      invite.insert_at(pos)
    else
      invite.errors.add(:position, "is not valid.")
      raise ActiveRecord::RecordInvalid, invite
    end
  end

  def create_primary_group(invite:, primary:)
    invite.update(primary: primary)
    primary.move_to_top
    invite.insert_at(2)
  end

  def assign_primary(invite:, primary:)
    raise_primary_error(invite, "invite and primary must belong to the same queue") if invite.invite_queue_id != primary.invite_queue_id
    raise_primary_error(invite, "alternates must be ungrouped before being reassigned") if invite.is_alternate?
    raise_primary_error(invite, "a primary with alternates must be ungrouped before being reassigned") if invite.has_alternates?
    raise_primary_error(invite, "an alternate cannot be assigned as a primary") if primary.is_alternate?
    raise_primary_error(invite, "sent invitations cannot have their primary assignment changed") unless invite.pending?

    if primary.has_alternates?
      last_alternate = primary.alternates.maximum(:position)
      invite.update(primary: primary)

      invite.reload.insert_at(last_alternate + 1)
    else
      create_primary_group(invite: invite, primary: primary)
    end
  end

  def unassign_primary_from(invite)
    raise_primary_error(invite, "invite already has no primary") if invite.primary.blank?
    raise_primary_error(invite, "a primary with alternates is not valid for unassigning") if invite.has_alternates?
    raise_primary_error(invite, "sent invitations cannot have their primary assignment changed") unless invite.pending?

    existing_primary = invite.primary
    invite.update(primary: nil)

    # if the primary has no more alternates it's ungrouped
    existing_primary.move_to_bottom unless existing_primary.has_alternates?

    invite.reload.move_to_bottom
  end

  def remove_invite(invite)
    raise_primary_error(invite, "a primary with alternates cannot be removed") if invite.has_alternates?

    invite.remove_from_list
    existing_primary = invite.primary

    invite.update(primary: nil, invite_queue: nil)
    existing_primary.move_to_bottom if existing_primary.try(:ungrouped_primary?)
  end

  def send_invite(invite)
    # Grouped primaries don't get reordered, just sent
    return invite.invite! if invite.has_alternates?

    new_position = if invite.is_alternate?
                     sent_alternate_position(invite)
                   else
                     sent_ungrouped_invite_position
                   end
    invite.invite!
    invite.insert_at(new_position)
  end

  private

  def sent_alternate_position(invite)
    primary = invite.primary
    (primary.alternates.not_pending.maximum(:position) || primary.position) + 1
  end

  def sent_ungrouped_invite_position
    # if there are sent ungrouped primaries, the invite goes below those
    sent_primaries = invitations.not_pending.all.select(&:ungrouped_primary?)
    if sent_primaries.present?
      sent_primaries.max_by(&:position).position + 1
    else
      # if there are none, the invite goes below the last grouped invite
      (invitations.grouped_alternates.maximum(:position) || 0) + 1
    end
  end

  def raise_primary_error(invite, msg)
    invite.errors.add(:primary, msg)
    raise ActiveRecord::RecordInvalid, invite
  end

  def raise_position_error(invite, msg)
    invite.errors.add(:position, msg)
    raise ActiveRecord::RecordInvalid, invite
  end
end
