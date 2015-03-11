class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :state, :title, :abstract, :email, :created_at, :invitee_id, :invitee_full_name, :invitee_avatar

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def invitee_full_name
    "#{object.invitee.first_name} #{object.invitee.last_name}"
  end

  def invitee_avatar
    object.invitee.avatar.url
  end
end
