class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :decline_reason,
             :email,
             :invitation_type,
             :invitee_role,
             :reviewer_suggestions,
             :state,
             :updated_at

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true, include: true
end
