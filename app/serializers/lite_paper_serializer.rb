class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles

  def paper_id
    id
  end

  def roles
    roles = object.paper_roles.map(&:description)
    roles << "My Paper" if current_user && object.user_id == current_user.id
  end
end
