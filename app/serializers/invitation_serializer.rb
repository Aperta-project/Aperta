class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :state,
             :email,
             :created_at,
             :updated_at,
             :invitation_type

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true, include: true

  def invitation_type
    object.invitee_role.capitalize
  end
end
