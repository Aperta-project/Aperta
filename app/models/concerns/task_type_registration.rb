module TaskTypeRegistration
  extend ActiveSupport::Concern

  module ClassMethods
    def register_task(default_title:, default_role:)
      TaskType.register(self, default_title, default_role)
    end
  end
end
