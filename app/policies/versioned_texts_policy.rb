class VersionedTextsPolicy < ApplicationPolicy
  primary_resource :versioned_text

  def show?
    papers_policy.show?
  end

  private

  def paper
    versioned_text.paper
  end

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: paper)
  end
end
