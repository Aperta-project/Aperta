class FlowQuery
  attr_reader :user, :flow

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    return Task.none if flow.query.empty?

    query_hash = HashWithIndifferentAccess.new(flow.query)
    scope = Task.all

    scope = by_journal(scope) unless user.site_admin?

    scope = assigned(scope, query_hash[:assigned])
    scope = state(scope, query_hash[:state])
    scope = role(scope, query_hash[:role])
    scope = type(scope, query_hash[:type])

    scope
  end

  def lite_papers
    Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks.pluck(:id)).
      uniq
  end

  private

  def state(scope, the_state)
    the_state ? scope.send(the_state) : scope
  end

  def role(scope, the_role)
    the_role ? scope.for_role(the_role) : scope
  end

  def assigned(scope, is_assigned)
    if is_assigned.nil?
      scope
    else
      is_assigned ? scope.assigned_to(user) : scope.unassigned
    end
  end

  def type(scope, the_type)
    if the_type && TaskType.types.include?(the_type)
      scope.where(type: the_type)
    else
      scope
    end
  end

  def by_journal(scope)
    journals = flow.default? ? user.journals : [flow.journal]
    scope.on_journals(journals)
  end
end
