class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :state,
             :title,
             :abstract,
             :email,
             :invitation_type,
             :invitee_id,
             :invitee_full_name,
             :invitee_avatar_url,
             :created_at,
             :updated_at

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def invitee_full_name
    return unless object.invitee.present?
    "#{object.invitee.first_name} #{object.invitee.last_name}"
  end

  def invitee_avatar_url
    return unless object.invitee.present?
    object.invitee.avatar.url
  end

  def invitation_type
    object.task.invitee_role.capitalize
  end
end
