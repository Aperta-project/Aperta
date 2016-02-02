module TaskTypeRegistration
  extend ActiveSupport::Concern

  module ClassMethods
    def register_task(default_title:, default_role:, required_permissions:[])
      TaskType.register(self, default_title, default_role, required_permissions)
    end
  end
end
