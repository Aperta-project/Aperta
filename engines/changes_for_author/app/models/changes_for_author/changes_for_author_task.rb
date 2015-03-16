module ChangesForAuthor
  class ChangesForAuthorTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    register_task default_title: "ChangesForAuthor Task", default_role: "author"

    def active_model_serializer
      TaskSerializer
    end

    def self.permitted_attributes
      super << :body
    end
  end
end
