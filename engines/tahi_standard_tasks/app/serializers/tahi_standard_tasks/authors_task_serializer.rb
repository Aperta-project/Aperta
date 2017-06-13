module TahiStandardTasks
  class AuthorsTaskSerializer < ::TaskSerializer
    has_many :authors, embed: :ids, include: true
    has_many :group_authors, embed: :ids, include: true

    def authors
      object.authors.includes(
        :author_list_item,
        answers: [:attachments]
      )
    end

    def group_authors
      object.group_authors.includes(
        :author_list_item,
        answers: [:attachments]
      )
    end
  end
end
