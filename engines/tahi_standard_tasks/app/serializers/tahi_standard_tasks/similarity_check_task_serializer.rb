# serializes sim check tasks
module TahiStandardTasks
  class SimilarityCheckTaskSerializer < ::TaskSerializer
    attributes :current_setting_value

    def current_setting_value
      object.task_template.setting('ithenticate_automation').try(:value)
    end
  end
end
