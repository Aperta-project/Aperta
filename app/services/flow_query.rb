class FlowQuery
  attr_reader :user, :flow

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    return Task.none if flow.query.blank?

    scope = by_journal(Task.all)

    flow.query.keys.each do |query_scope|
      scope = send(query_scope, scope)
    end

    scope
  end

  def papers
    Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks.pluck(:id)).
      uniq
  end

  private

  def state(scope)
    scope.send(flow.query[:state])
  end

  def old_role(scope)
    scope.for_old_role(flow.query[:old_role])
  end

  def assigned(scope)
    flow.query[:assigned] ? scope.assigned_to(user) : scope.unassigned
  end

  def type(scope)
    scope.where(type: flow.query[:type])
  end

  def by_journal(scope)
    journals = flow.default? ? user.accessible_journals : [flow.journal]
    scope.on_journals(journals)
  end
end
