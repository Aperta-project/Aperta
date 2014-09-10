module StandardTasks
  class AwesomeAuthorSerializer < ::AuthorSerializer
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
      :position,
      :awesome_name
    has_one :author_group, embed: :id
  end
end
