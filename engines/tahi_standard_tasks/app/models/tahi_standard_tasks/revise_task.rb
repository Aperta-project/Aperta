module TahiStandardTasks
  class ReviseTask < Task
    include SubmissionTask

    register_task default_title: "Revise Task", default_role: "author"

    def active_model_serializer
      ReviseTaskSerializer
    end
  end
end
