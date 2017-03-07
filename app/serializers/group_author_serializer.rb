# Serializer for authors that aren't individuals; they live in the
# same list as normal authors
class GroupAuthorSerializer < ActiveModel::Serializer
  include CardContentShim

  attributes :initial,
             :contact_first_name,
             :contact_middle_name,
             :contact_last_name,
             :contact_email,
             :position,
             :paper_id,
             :name,
             :id
end
