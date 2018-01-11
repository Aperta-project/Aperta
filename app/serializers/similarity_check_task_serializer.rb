# serializes sim check tasks
class SimilarityCheckTaskSerializer < ::TaskSerializer
  attributes :current_setting_value

  def current_setting_value
    return nil unless object.task_template
    object.task_template.setting('ithenticate_automation').try(:value)
  end
end
