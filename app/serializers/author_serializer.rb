class AuthorSerializer < ActiveModel::Serializer
  attributes :id,
    :first_name,
    :last_name,
    :position,
    :paper_id
end
