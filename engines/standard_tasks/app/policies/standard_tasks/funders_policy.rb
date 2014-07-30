module StandardTasks
  class FundersPolicy < ::ApplicationPolicy
    require_params :funder

    def create?
      can_administer_journal?(paper.journal) || author_of_paper?(funder.task.paper)
    end

    def update?
      can_administer_journal?(paper.journal) || author_of_paper?(funder.task.paper)
    end

    def destroy?
      can_administer_journal?(paper.journal) || author_of_paper?(funder.task.paper)
    end

    private

    def paper
      funder.task.paper
    end
  end
end
