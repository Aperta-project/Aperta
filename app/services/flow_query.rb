class FlowQuery
  attr_reader :user, :flow

  NON_SCOPED_FILTERS = [:assigned, :type]

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    return [] if flow.query.empty?
    query_hash = HashWithIndifferentAccess.new(flow.query)
    scope = Task.includes(:paper)
    scope = scope.assigned_to(user) if query_hash[:assigned]

    # TODO verify its a possible type
    scope = scope.where(type: query_hash[:type]) if query_hash[:type]

    unless user.site_admin?
      if flow.default?
        scope = scope.on_journals(user.journals)
      else
        scope = scope.on_journals([flow.journal])
      end
    end

    query_hash.keys.reject { |key| NON_SCOPED_FILTERS.include?(key.to_sym) }.each do |s|
      scope = scope.send(s)
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
