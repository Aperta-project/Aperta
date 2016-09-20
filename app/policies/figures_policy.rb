class FiguresPolicy < ApplicationPolicy
  primary_resource :figure
  allow_params :for_paper

  def index?
    papers_policy.show?
  end

  def create?
    papers_policy.show?
  end

  def update?
    papers_policy.show?
  end

  def destroy?
    papers_policy.show?
  end

  def update_attachment?
    papers_policy.show?
  end

  def show?
    papers_policy.show?
  end

  def cancel?
    papers_policy.show?
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(
      current_user: current_user,
      resource: for_paper || figure.paper)
  end
end
