class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :state, :title, :abstract, :email, :created_at

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end
end
