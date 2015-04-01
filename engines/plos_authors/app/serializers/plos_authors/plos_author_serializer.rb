module PlosAuthors
  class PlosAuthorSerializer < ::AuthorSerializer

    attributes :middle_initial,
               :email,
               :affiliation,
               :secondary_affiliation,
               :title,
               :corresponding,
               :deceased,
               :department,
               :contributions

    has_one :plos_authors_task, embed: :id

  end
end
