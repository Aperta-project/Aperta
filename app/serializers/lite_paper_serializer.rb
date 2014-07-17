class LitePaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :paper_id, :short_title, :submitted, :roles

  def paper_id
    id
  end

  def roles
    roles = object.role_descriptions
  end

end
