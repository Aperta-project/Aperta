class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :created_at

  has_one :paper, embed: :id
  has_one :user, embed: :id, include: true

  def paper
    object.assigned_to
  end

end
