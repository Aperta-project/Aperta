class LitePaperSerializer < ActiveModel::Serializer
  attributes :aarx_doi, :active, :created_at, :editable, :file_type, :id, :journal_id, :manuscript_id,
             :processing, :publishing_state, :related_at_date, :roles, :short_doi,
             :title, :updated_at, :review_due_at, :review_originally_due_at

  def related_at_date
    return unless scoped_user.present?
    my_roles.map(&:created_at).sort.last
  end

  def roles
    return unless scoped_user.present?
    object.role_descriptions_for(user: scoped_user)
  end

  def review_due_at
    return unless scope && reviewer_report
    @review_due_at ||= reviewer_report.due_at
  end

  def review_originally_due_at
    return unless scope && reviewer_report
    # originally_due_at is only returned if it needs to be displayed
    return if reviewer_report.originally_due_at == review_due_at
    reviewer_report.originally_due_at
  end

  private

  def my_roles
    @my_roles ||= object.roles_for(user: scoped_user)
  end

  def scoped_user
    scope.presence || options[:user]
  end

  def reviewer_report
    @reviewer_report ||= scope.reviewer_reports.joins(:task, :paper).where(papers: { id: id }).first
  end
end
