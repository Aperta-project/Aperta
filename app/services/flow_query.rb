class FlowQuery
  attr_reader :user, :flow

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    return [] if flow.query.empty?
    query_hash = HashWithIndifferentAccess.new(flow.query)
    scope = Task.includes(:paper)

    if query_hash[:assigned]
      scope = scope.assigned_to(user) 
    elsif query_hash[:assigned] == false
      scope = scope.unassigned
    end

    scope = scope.send(query_hash[:state]) if query_hash[:state]
    scope = scope.for_role(query_hash[:role]) if query_hash[:role]

    if query_hash[:type] && TaskType.types.include?(query_hash[:type])
      scope = scope.where(type: query_hash[:type])
    end

    unless user.site_admin?
      if flow.default?
        scope = scope.on_journals(user.journals)
      else
        scope = scope.on_journals([flow.journal])
      end
    end

    scope
  end

  def lite_papers
    Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks.map(&:id)).
      uniq
  end

  private

  def attached_journal_ids
    @attached_journal_ids ||= user.roles.pluck(:journal_id).uniq
  end
end
