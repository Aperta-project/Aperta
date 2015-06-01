module TahiStandardTasks
  class CoverLetterTask < Task
    include MetadataTask

    register_task default_title: 'Cover Letter', default_role: 'author'

    def active_model_serializer
      TaskSerializer
    end
  end
end

