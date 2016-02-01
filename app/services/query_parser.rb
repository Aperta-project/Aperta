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
class QueryParser
  extend QueryLanguageParser
  extend Rsec::Helpers

  def self.build(str)
    clear_joins
    query = parse str
    @root.where(query)
  end

  paper_table = Paper.arel_table

  add_simple_expression(keyword: 'STATUS IS NOT') do |status|
    paper_table[:publishing_state].not_eq(status)
  end

  add_simple_expression(keyword: 'STATUS IS') do |status|
    paper_table[:publishing_state].eq(status)
  end

  add_simple_expression(keyword: 'TYPE IS NOT') do |type|
    paper_table[:paper_type].not_eq(type)
  end

  add_simple_expression(keyword: 'TYPE IS') do |type|
    paper_table[:paper_type].eq(type)
  end

  add_expression(keywords: ['TITLE IS']) do |_|
    symbol('TITLE IS') >> /.*/.r.map do |title|
      title_query(title)
    end
  end

  add_simple_expression(keyword: 'DECISION IS NOT') do |decision|
    join Decision
    Decision.arel_table[:verdict].not_eq(decision)
  end

  add_simple_expression(keyword: 'DECISION IS') do |decision|
    join Decision
    Decision.arel_table[:verdict].eq(decision)
  end

  add_simple_expression(keyword: 'DOI IS') do |doi|
    paper_table[:doi].matches("%#{doi}%")
  end

  add_statement(/^\d+/.r.map { |doi| paper_table[:doi].matches("%#{doi}%") })

  add_statement(/^.+/.r.map { |title| title_query(title) })

  add_statement(/^$/.r.map { paper_table[:id].not_eq(nil) })

  class << self
    def clear_joins
      @joins = []
      @root = Paper
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
end
