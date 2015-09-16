class AuthorSerializer < ActiveModel::Serializer
  attributes :affiliation, :contributions, :corresponding, :deceased, :department,
             :email, :first_name, :id, :last_name, :middle_initial, :paper_id,
             :position, :secondary_affiliation, :title

  has_one :authors_task, embed: :id
end
