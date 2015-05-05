class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :state,
             :email,
             :created_at,
             :updated_at

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
end
