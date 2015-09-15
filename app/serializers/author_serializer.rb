class AuthorSerializer < ActiveModel::Serializer
  attributes :id,
    :paper_id,
    :position,
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
    :contributions

  has_one :authors_task, embed: :id
end
