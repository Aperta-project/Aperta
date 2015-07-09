module PlosAuthors
  class PlosAuthorsPolicy < ::ApplicationPolicy
    primary_resource :plos_author

    include TaskAccessCriteria

    def show?
      authorized_to_modify_task?
    end

    def create?
      authorized_to_modify_task?
    end

    def update?
      authorized_to_modify_task?
    end

    def destroy?
      authorized_to_modify_task?
    end

    private

    def task
      plos_author.plos_authors_task
    end
  end
end
