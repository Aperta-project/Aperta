class InvitationIndexSerializer < ActiveModel::Serializer
  self.root = :invitation

  attributes :id,
             :state,
             :title,
             :abstract,
             :email,
             :invitee_role,
             :created_at,
             :updated_at,
             :invitee_id,
             :information,
             :paper_type

  has_one :task, embed: :id, polymorphic: true

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def paper_type
    object.paper.paper_type
  end
end
