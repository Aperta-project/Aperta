module PlosAuthors
  class PlosAuthorsTaskSerializer < ::TaskSerializer
    has_many :plos_authors, embed: :ids, include: true

    def plos_authors
      # generic Authors may have been created in a different task, so
      # convert them to PlosAuthors before serializing
      object.convert_generic_authors!
      object.plos_authors
    end
  end
end
