class FlowQuery
  attr_reader :user, :flow

  USER_FILTERS = [:assigned]

  def initialize(user, flow)
    @user = user
    @flow = flow
  end

  def tasks
    arr = flow.query
    scope = Task.includes(:paper)
    scope = scope.assigned_to(user) if arr.include?(:assigned)

    unless user.site_admin?
      if flow.default?
        scope = scope.on_journals(user.journals)
      else
        scope = scope.on_journals([flow.journal])
      end
    end

    arr.reject { |key| USER_FILTERS.include?(key) }.each do |s|
      scope = scope.send(s)
    end

    scope
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks.pluck(:id)).
      uniq
  end

  private

  def attached_journal_ids
    @attached_journal_ids ||= user.roles.pluck(:journal_id).uniq
  end
end
