# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'query_language_parser'

##
# This defines our particular query language.
#
# It uses arel queries instead of ActiveRelations, which may look odd.
# Unfortunately, ActiveRelation doesn't support the AND/OR boolean
# logic our query language uses.
#
# When adding expressions and statements, ORDER MATTERS! Expressions
# earlier on the page will take precedence over those later, so (for
# example) X IS NOT should come before X IS.
#
class QueryParser < QueryLanguageParser
  extend Rsec::Helpers

  paper_table = Paper.arel_table

  add_simple_expression('STATUS IS NOT') do |status|
    paper_table[:publishing_state].not_eq(status.parameterize.underscore)
  end

  add_simple_expression('STATUS IS') do |status|
    paper_table[:publishing_state].eq(status.parameterize.underscore)
  end

  add_simple_expression('TYPE IS NOT') do |type|
    paper_table[:paper_type].does_not_match(type)
  end

  add_simple_expression('TYPE IS') do |type|
    paper_table[:paper_type].matches(type)
  end

  add_simple_expression('DECISION IS NOT') do |decision|
    verdict = decision.parameterize.underscore
    decision_where(Decision.arel_table[:verdict].not_eq(verdict))
  end

  add_simple_expression('DECISION IS') do |decision|
    verdict = decision.parameterize.underscore
    decision_where(Decision.arel_table[:verdict].eq(verdict))
  end

  add_simple_expression('DOI IS') do |doi|
    paper_table[:doi].matches("%#{doi}%")
  end

  add_two_part_expression('USER', 'HAS ROLE') do |username, role|
    user_id = get_user_id(username)
    role_ids = Role.where('lower(name) = ?', role.downcase)
                   .pluck(:id).sort

    table = join(Assignment, 'assigned_to_id')
    table['user_id'].eq(user_id)
      .and(table['role_id'].in(role_ids))
      .and(table['assigned_to_type'].eq('Paper'))
  end

  add_two_part_expression('USER', 'HAS ANY ROLE') do |username, _|
    user_id = get_user_id(username)

    table = join(Assignment, 'assigned_to_id')
    table['user_id'].eq(user_id).and(table['assigned_to_type'].eq('Paper'))
  end

  add_simple_expression('ANYONE HAS ROLE') do |role|
    role_ids = Role.where('lower(name) = ?', role.downcase)
                   .pluck(:id)

    table = join(Assignment, 'assigned_to_id')
    table['role_id'].in(role_ids).and(table['assigned_to_type'].eq('Paper'))
  end

  add_simple_expression('NO ONE HAS ROLE') do |role|
    role_ids = Role.where('lower(name) = ?', role.downcase)
                   .pluck(:id)

    assignment = Assignment.arel_table
    paper_table[:id].not_in(
      Arel::Nodes::SqlLiteral.new(
        assignment.project(:assigned_to_id)
                  .where(assignment[:role_id].in(role_ids)
                  .and(assignment[:assigned_to_type].eq('Paper'))).to_sql))
  end

  add_two_part_expression('TASK', 'IS COMPLETE') do |task, _|
    table = join Task
    table[:title].matches(task).and(table[:completed].eq(true))
  end

  add_two_part_expression('TASK', 'HAS OPEN INVITATIONS') do |task, _|
    task_table = join Task
    invite_table = join Invitation, "task_id", task_table.table_alias + ".id"
    task_table[:title].matches(task).and(
      invite_table[:state].in(%w(pending invited)))
  end

  add_two_part_expression('TASK', 'HAS NO OPEN INVITATIONS') do |task, _|
    task_table = join Task
    invite_table = join Invitation, "task_id", task_table.table_alias + ".id"
    task_table[:title].matches(task).and(
      invite_table[:state].not_in(%w(pending invited)))
  end

  add_two_part_expression('TASK',
                          /IS NOT COMPLETE|IS INCOMPLETE/) do |task, _|
    table = join Task
    table[:title].matches(task).and(table[:completed].eq(false))
  end

  add_two_part_expression('TASK', /HAS BEEN COMPLETED? \>/) do |task, days_ago|
    table = join Task
    start_time = Time.zone.now.utc.days_ago(days_ago.to_i).to_formatted_s(:db)
    table[:title].matches(task).and(table[:completed_at].lt(start_time))
  end

  add_simple_expression('HAS TASK') do |task|
    table = join Task
    table[:title].matches(task)
  end

  add_simple_expression('HAS NO TASK') do |task|
    paper_table[:id].not_in(
      Arel::Nodes::SqlLiteral.new(
        Task.arel_table.project(:paper_id).where(
          Task.arel_table[:title].matches(task)).to_sql))
  end

  add_no_args_expression('ALL REVIEWS COMPLETE') do
    task_table = Task.arel_table
    incomplete_reviews = task_table.project(:paper_id).where(
      task_table[:type].in(sti_helper TahiStandardTasks::ReviewerReportTask)
      .and(task_table[:completed].eq(false)))

    joined_tasks = join Task

    paper_table[:id].not_in(
      Arel::Nodes::SqlLiteral.new(incomplete_reviews.to_sql)).and(
        joined_tasks[:type].in(sti_helper TahiStandardTasks::ReviewerReportTask))
  end

  add_no_args_expression('NOT ALL REVIEWS COMPLETE') do
    table = join Task

    table[:type].in(sti_helper TahiStandardTasks::ReviewerReportTask)
      .and(table[:completed].eq(false))
  end

  add_simple_expression('SUBMITTED >') do |days_ago|
    start_time = Time.zone.now.utc.days_ago(days_ago.to_i).to_formatted_s(:db)
    paper_table[:submitted_at].lt(start_time)
  end

  add_simple_expression('SUBMITTED <') do |days_ago|
    start_time = Time.zone.now.utc.days_ago(days_ago.to_i).to_formatted_s(:db)
    paper_table[:submitted_at].gteq(start_time)
  end

  add_statement(/^\d+/.r) do |doi|
    paper_table[:doi].matches("%#{doi}%")
  end

  add_expression(keywords: ['TITLE IS']) do |_|
    symbol('TITLE IS') >> /.*/m.r.map do |title|
      title_query(title)
    end
  end

  add_statement(/^.+/m.r) do |title|
    title_query(title)
  end

  add_statement(/^$/.r) do
    paper_table[:id].not_eq(nil)
  end

  def initialize(current_user: nil)
    @current_user = current_user
    @join_counter = 0
    @root = Paper
  end

  def build(str)
    query = parse str
    @root.where(query).uniq
  end

  private

  def get_user_id(username)
    user = nil

    if username == "me"
      user = @current_user
    else
      user = User.find_by(username: username)
    end

    user ? user.id : -1
  end

  def join(klass, id = "paper_id", join_id = "papers.id")
    table = klass.table_name
    name = "#{table}_#{@join_counter}"
    @root = @root.joins(<<-SQL)
      INNER JOIN #{table} AS #{name} ON #{name}.#{id} = #{join_id}
    SQL
    @join_counter += 1
    klass.arel_table.alias(name)
  end

  def title_query(title)
    ##
    # Arel doesn't have a built-in text search node, so we have to
    # build our own.
    #
    # Note that Postgres full-text search does stemming and stop
    # words; so don't expect results from 'the' or 'with'.
    #
    title_col = Paper.arel_table[:title]
    language = Arel::Nodes.build_quoted('english')
    title_vector = Arel::Nodes::NamedFunction.new(
      'to_tsvector',
      [language, title_col])

    quoted_query_str = Arel::Nodes.build_quoted(title.gsub(/\s+/, '&'))
    query_vector = Arel::Nodes::NamedFunction.new(
      'to_tsquery',
      [language, quoted_query_str])

    Arel::Nodes::InfixOperation.new('@@', title_vector, query_vector)
  end

  def sti_helper(parent_class)
    [parent_class] + parent_class.descendants
  end

  def decision_where(where_clause)
    decision_table = Decision.arel_table
    decision_alias = "decisions_#{@join_counter}"
    @join_counter += 1
    latest_decisions = decision_table.project(
      :paper_id,
      decision_table[:revision_number].maximum.as('revision_number'))
                       .where(decision_table[:verdict].not_eq(nil))
                       .group(:paper_id)
                       .to_sql
    # Unfortunately, Arel doesn't cope with selecting from
    # sub-selects, so we've got to drop into raw SQL for this bit.
    good_decisions = <<-SQL.strip_heredoc + where_clause.to_sql
    SELECT #{decision_alias}.paper_id from (#{latest_decisions})
        AS #{decision_alias}
    INNER JOIN decisions ON
        decisions.paper_id = #{decision_alias}.paper_id
        AND decisions.revision_number = #{decision_alias}.revision_number
    WHERE
    SQL

    Paper.arel_table[:id].in(Arel::Nodes::SqlLiteral.new(good_decisions))
  end
end
