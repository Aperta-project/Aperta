class InvitationIndexSerializer < ActiveModel::Serializer
  attributes :id,
             :state,
             :title,
             :abstract,
             :email,
             :invitation_type,
             :created_at,
             :updated_at,
             :invitee_id,
             :information

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def invitation_type
    object.task.invitee_role.capitalize
  end
end
