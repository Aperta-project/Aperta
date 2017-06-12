# serializes sim check tasks
module TahiStandardTasks
  class SimilarityCheckTaskSerializer < ::TaskSerializer
    attributes :current_setting_value

    def current_setting_value
      object.task_template.settings.first.value
    end
  end
end
