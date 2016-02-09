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
    join Decision
    Decision.arel_table[:verdict].not_eq(decision.parameterize.underscore)
  end

  add_simple_expression('DECISION IS') do |decision|
    join Decision
    Decision.arel_table[:verdict].eq(decision.parameterize.underscore)
  end

  add_simple_expression('DOI IS') do |doi|
    paper_table[:doi].matches("%#{doi}%")
  end

  add_statement(/^\d+/.r) do |doi|
    paper_table[:doi].matches("%#{doi}%")
  end

  add_expression(keywords: ['TITLE IS']) do |_|
    symbol('TITLE IS') >> /.*/.r.map do |title|
      title_query(title)
    end
  end

  add_statement(/^.+/.r) do |title|
    title_query(title)
  end

  add_statement(/^$/.r) do
    paper_table[:id].not_eq(nil)
  end

  def initialize
    @joins = []
    @root = Paper
  end

  def build(str)
    query = parse str
    @root.where(query)
  end

  private

  def join(klass)
    return if @joins.include? klass
    @root = @root.joins(klass.table_name.to_sym)
    @joins.push klass
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

    quoted_query_str = Arel::Nodes.build_quoted(title.gsub(/\s/, '&'))
    query_vector = Arel::Nodes::NamedFunction.new(
      'to_tsquery',
      [language, quoted_query_str])

    Arel::Nodes::InfixOperation.new('@@', title_vector, query_vector)
  end
end
