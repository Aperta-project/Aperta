class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :created_at,
             :decline_reason,
             :email,
             :invitee_role,
             :reviewer_suggestions,
             :state,
             :updated_at,
             :invited_at,
             :declined_at,
             :accepted_at,
             :rescinded_at,
             :position,
             :decision_id

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true
  has_many :attachments, embed: :id, polymorphic: true, include: true
  has_one :primary, embed: :id
  has_many :alternates, embed: :id
end
