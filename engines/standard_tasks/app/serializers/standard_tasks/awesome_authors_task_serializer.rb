module StandardTasks
  class AwesomeAuthorsTaskSerializer < ::TaskSerializer
    has_many :awesome_authors
  end
end
