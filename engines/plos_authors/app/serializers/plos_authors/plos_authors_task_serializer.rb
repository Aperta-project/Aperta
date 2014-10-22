module PlosAuthors
  class PlosAuthorsTaskSerializer < ::TaskSerializer
    has_many :plos_authors, embed: :ids, include: true

    def plos_authors
      object.plos_authors
    end
  end
end
