module TahiStandardTasks
  ##
  # Controls access to apex deliveries. This set of permissions will
  # be exactly the same list as is allowed to view and modify the Send
  # to Apex task.
  #
  class ApexDeliveriesPolicy < ::TasksPolicy
    primary_resource :apex_delivery

    include TaskAccessCriteria

    def create?
      authorized_to_modify_task?
    end

    def show?
      authorized_to_modify_task?
    end

    private

    delegate :task, to: :apex_delivery
  end
end
