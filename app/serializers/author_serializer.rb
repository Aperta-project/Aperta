class AuthorSerializer < ActiveModel::Serializer
  attributes :id,
    :first_name,
    :middle_initial,
    :last_name,
    :email,
    :affiliation,
    :secondary_affiliation,
    :title,
    :corresponding,
    :deceased,
    :department,
    :position
  has_one :author_group, embed: :id
end
