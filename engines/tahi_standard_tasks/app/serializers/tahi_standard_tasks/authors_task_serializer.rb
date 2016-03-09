module TahiStandardTasks
  class AuthorsTaskSerializer < ::TaskSerializer
    has_many :authors, embed: :ids, include: true
    has_many :group_authors, embed: :ids, include: true
  end
end
