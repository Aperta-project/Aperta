module StandardTasks
  class AwesomeAuthorsTaskSerializer < ::TaskSerializer
    has_many :awesome_authors, embed: :ids, include: true
  end
end
