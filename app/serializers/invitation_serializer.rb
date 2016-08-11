class InvitationSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :created_at,
             :decline_reason,
             :email,
             :invitee_role,
             :reviewer_suggestions,
             :state,
             :updated_at

  has_one :invitee, serializer: UserSerializer, embed: :id, root: :users, include: true
  has_one :task, embed: :id, polymorphic: true

  def include_body?
    @options[:include_body] == true
  end
end
