module Typesetter
  # Serializes authors and group authors for the typesetter.
  # Expects an authors task as its object to serialize.
  class AuthorsSerializer < Typesetter::TaskAnswerSerializer
    self.root = false
    has_one :author_or_group_author, key: :author

    def author_or_group_author
      if object.author_type == "Author"
        Typesetter::IndividualAuthorSerializer.new(
          Author.find(object.author_id))
      else
        Typesetter::GroupAuthorSerializer.new(
          GroupAuthor.find(object.author_id))
      end
    end

    def authors
      (individual_authors + group_authors).sort_by { |a| a[:position] }.each \
        do |a|
          # For some reason positions aren't being stored sequentially.  They
          # don't necessarily start at 1 and they can skip numbers.  The final
          # order is correct, however.  So as to not confuse Apex, I'm just
          # omitting that key for now
          a.delete :position
        end
    end

    def individual_authors
      object.authors
        .includes(:author_list_item)
        .map do |author|
          Typesetter::IndividualAuthorSerializer.new(author)
        end

      # ensure_corresponding_author(authors, object.paper.creator)
    end

    def group_authors
      object.group_authors
        .includes(:author_list_item)
        .map do |author|
          Typesetter::GroupAuthorSerializer.new(author)
        end
    end

    def ensure_corresponding_author(authors, creator)
      if authors.count { |a| a[:corresponding] == true } == 0
        authors.map do |author|
          author[:corresponding] = author[:email] == creator.email
        end
      end
      authors
    end
  end
end
