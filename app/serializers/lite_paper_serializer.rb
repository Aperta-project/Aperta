class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles

  def paper_id
    id
  end

  def roles
    roles = []
    if defined?(current_user) && current_user
      # rocking this in memory because eager-loading
      roles = object.paper_roles.select { |role|
        role.user_id == current_user.id
      }.map(&:description)
      roles << "My Paper" if object.user_id == current_user.id
    end
    roles
  end
end
