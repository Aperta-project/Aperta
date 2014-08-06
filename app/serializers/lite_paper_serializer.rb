class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles

  def paper_id
    id
  end

  def roles
    roles = object.paper_roles.select(:role).distinct.map(&:description)
    if defined?(current_user) && current_user && object.user_id == current_user.id
      roles << "My Paper"
    end
    roles
  end
end
