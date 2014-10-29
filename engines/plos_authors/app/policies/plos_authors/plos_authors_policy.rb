module PlosAuthors
  class PlosAuthorsPolicy < ::ApplicationPolicy
    require_params :task
    include TaskAccessCriteria

    def create?
      authorized_to_modify_task?
    end

    def update?
      authorized_to_modify_task?
    end

    def destroy?
      authorized_to_modify_task?
    end
  end
end
