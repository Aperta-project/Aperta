class InvitationIndexSerializer < ActiveModel::Serializer
  self.root = :invitation

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

  has_one :task, embed: :id, polymorphic: true

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def invitation_type
    object.invitee_role.capitalize
  end
end
