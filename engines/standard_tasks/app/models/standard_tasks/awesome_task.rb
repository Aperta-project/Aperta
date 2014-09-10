module StandardTasks
  class AwesomeTask < Task
    title "Awesome Task"
    role "author"

    has_many :awesome_authors
    accepts_nested_attributes_for :awesome_authors

    validates_associated :awesome_authors

    def active_model_serializer
      TaskSerializer
    end
  end
end
