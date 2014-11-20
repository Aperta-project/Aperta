module StandardTasks
  class FiguresPolicy < ::ApplicationPolicy
    primary_resource :figure

    def create?
      can_view_paper?
    end

    def update?
      can_view_paper?
    end

    def destroy?
      can_view_paper?
    end

    private

    def paper
      figure.paper
    end
  end
end
