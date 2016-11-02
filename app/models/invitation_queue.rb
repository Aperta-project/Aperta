# Queues are used to hold groups of invitations that can either be
# sent individually or at a later time.
class InvitationQueue < ActiveRecord::Base
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

  def add_invitation(invitation)
    # acts_as_list always puts new items at the bottom of the list by default,
    # so we don't need to do anything further.
    validates_unique_positions(invitation) do
      invitation.update(invitation_queue: self)
      invitation.move_to_bottom
    end
  end

  def valid_new_positions_for_invitation(invitation)
    return [] if invitation.has_alternates? || !invitation.pending?
    valid_invitations = if invitation.is_alternate?
                          invitation.primary.alternates
                        else
                          invitations.reload.select(&:ungrouped_primary?)
                        end

    valid_invitations
      .select(&:pending?)
      .reject { |i| i.id == invitation.id }
      .map(&:position)
  end

  def move_invitation_to_position(invitation, pos)
    raise_position_error(invitation, "unpersisted invitation called") unless invitation.persisted?
    raise_position_error(invitation, "new position is not valid") unless valid_new_positions_for_invitation(invitation).include?(pos)

    validates_unique_positions(invitation) do
      invitation.insert_at(pos)
    end
  end

  def create_primary_group(invitation:, primary:)
    validates_unique_positions(invitation) do
      new_position = (invitations.grouped_alternates.maximum(:position) || 0) + 1

      invitation.update(primary: primary)
      primary.insert_at(new_position)
      invitation.reload.insert_at(new_position + 1)
    end
  end

  def assign_primary(invitation:, primary:)
    raise_primary_error(invitation, "invitation and primary must belong to the same queue") if invitation.invitation_queue_id != primary.invitation_queue_id
    raise_primary_error(invitation, "a primary with alternates must be ungrouped before being reassigned") if invitation.has_alternates?
    raise_primary_error(invitation, "an alternate cannot be assigned as a primary") if primary.is_alternate?
    raise_primary_error(invitation, "sent invitations cannot have their primary assignment changed") unless invitation.pending?

    validates_unique_positions(invitation) do
      unassign_primary_from(invitation) if invitation.primary

      if primary.has_alternates?
        last_alternate = primary.alternates.maximum(:position)
        invitation.update(primary: primary)

        invitation.reload.insert_at(last_alternate + 1)
      else
        create_primary_group(invitation: invitation, primary: primary)
      end
    end
  end

  def unassign_primary_from(invitation)
    raise_primary_error(invitation, "invitation already has no primary") if invitation.primary.blank?
    raise_primary_error(invitation, "a primary with alternates is not valid for unassigning") if invitation.has_alternates?
    raise_primary_error(invitation, "sent invitations cannot have their primary assignment changed") unless invitation.pending?

    validates_unique_positions(invitation) do
      existing_primary = invitation.primary
      invitation.update(primary: nil)

      # if the primary has no more alternates it's ungrouped
      existing_primary.move_to_bottom unless existing_primary.has_alternates?

      invitation.reload.move_to_bottom
    end
  end

  def destroy_invitation(invitation)
    raise_primary_error(invitation, "a primary with alternates cannot be removed") if invitation.has_alternates?

    validates_unique_positions(invitation) do
      existing_primary = invitation.primary
      invitation.destroy!

      existing_primary.move_to_bottom if existing_primary.try(:ungrouped_primary?)
    end
  end

  def send_invitation(invitation)
    validates_unique_positions(invitation) do
      # Grouped primaries don't get reordered, just sent
      return invitation.invite! if invitation.has_alternates?

      new_position = if invitation.is_alternate?
                       sent_alternate_position(invitation)
                     else
                       sent_ungrouped_invitation_position
                     end
      invitation.invite!
      invitation.insert_at(new_position)
    end
  end

  private

  # We're unable to use a DB constraint to validate the uniqueness of positions within
  # the list due to how acts_as_list modifies them, but we can check after the fact.
  def validates_unique_positions(invitation)
    Invitation.transaction do
      yield

      positions = invitations.pluck(:position)
      raise_position_error(invitation, "unique position violation") if positions.uniq.count != positions.count
    end
  end

  def sent_alternate_position(invitation)
    primary = invitation.primary
    (primary.alternates.not_pending.maximum(:position) || primary.position) + 1
  end

  def sent_ungrouped_invitation_position
    # if there are sent ungrouped primaries, the invitation goes below those
    sent_primaries = invitations.not_pending.all.select(&:ungrouped_primary?)
    if sent_primaries.present?
      sent_primaries.max_by(&:position).position + 1
    else
      # if there are none, the invitation goes below the last grouped invitation
      (invitations.grouped_alternates.maximum(:position) || 0) + 1
    end
  end

  def raise_primary_error(invitation, msg)
    invitation.errors.add(:primary, msg)
    raise ActiveRecord::RecordInvalid, invitation
  end

  def raise_position_error(invitation, msg)
    invitation.errors.add(:position, msg)
    raise ActiveRecord::RecordInvalid, invitation
  end
end
