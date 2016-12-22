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

  add_two_part_expression('TASK', /HAS BEEN COMPLETED?/) do |task, days_ago|
    comparator = days_ago.match(/[<=>]{1,2}/).to_s
    if comparator.present?
      table = join Task
      table[:title].matches(task).and(
        date_query(
          parse_utc_date(days_ago),
          field: table[:completed_at],
          search_term: days_ago,
          default_comparison: comparator
        )
      )
    else
      # Better to return no results than false results.  If the user is missing the comparator
      # or did not include 'days ago' it will return no results.
      # The following is an impossible condition in order to return no results
      table[:completed].eq(false).and(table[:completed].eq(true))
    end
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
      task_table[:type].in(types_for_sti TahiStandardTasks::ReviewerReportTask)
      .and(task_table[:completed].eq(false)))

    joined_tasks = join Task

    paper_table[:id].not_in(
      Arel::Nodes::SqlLiteral.new(incomplete_reviews.to_sql)).and(
        joined_tasks[:type].in(types_for_sti TahiStandardTasks::ReviewerReportTask))
  end

  add_no_args_expression('NOT ALL REVIEWS COMPLETE') do
    table = join Task

    table[:type].in(types_for_sti TahiStandardTasks::ReviewerReportTask)
      .and(table[:completed].eq(false))
  end

  add_simple_expression(/VERSION DATE?/) do |date_string|
    comparator = date_string.match(/[<=>]{1,2}/).to_s
    date_query(
      parse_utc_date(date_string),
      field: paper_table[:submitted_at],
      search_term: date_string,
      default_comparison: comparator
    )
  end

  add_simple_expression(/SUBMISSION DATE?/) do |date_string|
    comparator = date_string.match(/[<=>]{1,2}/).to_s
    date_query(
      parse_utc_date(date_string),
      field: paper_table[:first_submitted_at],
      search_term: date_string,
      default_comparison: comparator
    )
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

  # Parses the given string
  def parse_utc_date(str)
    date_without_comparator = str.match(/(?![<=>]{1,2}\s+)[^\s].*/).to_s
    days_string_exists = date_without_comparator.downcase.match(' days? ago')
    if days_string_exists
      number_of_days = date_without_comparator.match(/\d+/).to_s.to_i
      days_ago_time = Time.zone.now.utc.days_ago(number_of_days)
    else
      (Chronic.parse(date_without_comparator).try(:utc) || Time.now.utc).to_date
    end
  end

  # Builds and adds a time query to the current query using the given arguments:
  #
  #  * time - the time to be used in the query, e.g. Time.zone.now.utc
  #
  #  * field: the AREL table field that should be used in the query, e.g. \
  #    Paper.arel_table[:submitted_at]
  #
  #  * search_term: the user-provided search term string, e.g. "3 days ago". \
  #    This is used to see if the default comparison should be used or if its \
  #    inverse should be used, e.g. "3 DAYS AGO" indicates an inverse seach \
  #    whereas "2016/09/01" indicates a normal search.
  #
  #  * default_comparison: the default comparison that the query should built \
  #    for, e.g. '>' or '<'.
  def date_query(date, field:, search_term:, default_comparison: '>')
    beginning_of_day_date = date.beginning_of_day.to_formatted_s(:db)
    end_of_day_date = date.end_of_day.to_formatted_s(:db)

    case default_comparison
    when '>'
      if search_term =~ /ago/i
        field.lt(beginning_of_day_date)
      else
        field.gt(end_of_day_date)
      end
    when '<'
      if search_term =~ /ago/i
        field.gt(end_of_day_date)
      else
        field.lt(beginning_of_day_date)
      end
    when '<='
      if search_term =~ /ago/i
        field.gteq(end_of_day_date)
      else
        field.lteq(beginning_of_day_date)
      end
    when '>='
      if search_term =~ /ago/i
        field.lteq(beginning_of_day_date)
      else
        field.gteq(end_of_day_date)
      end
    when '='
      # since the current fields are always datetime so we need to do a
      # BETWEEN check between the beginning and end of the day
      field.between(beginning_of_day_date..end_of_day_date)
    else
      fail ArgumentError, <<-ERROR.strip_heredoc.gsub(/\n/, ' ')
        Expected :comparison to be '>' or '<', but it was
        #{comparison.inspect}
      ERROR
    end
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

  def types_for_sti(parent_class)
    [parent_class] + parent_class.descendants
  end

  def decision_where(where_clause)
    decision_table = Decision.arel_table
    decision_alias = "decisions_#{@join_counter}"
    @join_counter += 1
    latest_decisions = decision_table.project(
      :paper_id,
      decision_table[:registered_at].maximum.as('registered_at'))
      .where(decision_table[:registered_at].not_eq(nil)
             .and(decision_table[:rescinded].not_eq(true)))
      .group(:paper_id)
      .to_sql
    # Unfortunately, Arel doesn't cope with selecting from
    # sub-selects, so we've got to drop into raw SQL for this bit.
    good_decisions = <<-SQL.strip_heredoc + where_clause.to_sql
    SELECT #{decision_alias}.paper_id from (#{latest_decisions})
        AS #{decision_alias}
    INNER JOIN decisions ON
        decisions.paper_id = #{decision_alias}.paper_id
        AND decisions.registered_at = #{decision_alias}.registered_at
    WHERE
    SQL

    Paper.arel_table[:id].in(Arel::Nodes::SqlLiteral.new(good_decisions))
  end
end
