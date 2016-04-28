module Typesetter
  # Serializes authors and group authors for the typesetter.
  # Expects an author as its object to serialize.
  class AuthorsSerializer < Typesetter::TaskAnswerSerializer
    def serializable_hash
      authors = object.authors
        .includes(:author_list_item)
        .map do |author|
          Typesetter::AuthorSerializer.new(author).serializable_hash
        end

      group_authors = object.group_authors
        .includes(:author_list_item)
        .map do |author|
          Typesetter::GroupAuthorSerializer.new(author).serializable_hash
        end

      (authors + group_authors).sort_by { |a| a[:position] }.each do |a|
        # For some reason positions aren't being stored sequentially.  They
        # don't necessarily start at 1 and they can skip numbers.  The final
        # order is correct, however.  So as to not confuse Apex, I'm just
        # omitting that key for now
        a.delete :position
      end
    end
  end
end
