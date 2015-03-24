module PlosAuthors
  class PlosAuthorsTaskSerializer < ::TaskSerializer
    has_many :plos_authors, embed: :ids, include: true
  end
end
