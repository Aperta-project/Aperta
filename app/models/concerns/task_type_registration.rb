module TaskTypeRegistration
  extend ActiveSupport::Concern

  module ClassMethods
    def register_task(default_title:, default_role:,
      required_permission_action: nil, required_permission_applies_to: nil)
      TaskType.register(self, default_title, default_role,
        required_permission_action, required_permission_applies_to)
    end
  end
end
