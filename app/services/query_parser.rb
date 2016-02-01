##
# This defines our particular query language.
#
# ORDER MATTERS! Expressions earlier on the page will take
# precedence.
class QueryParser
  extend QueryLanguageParser
  extend Rsec::Helpers

  def self.join(klass)
    unless @joins.include? klass
      @root = @root
              .join(klass.arel_table)
              .on(klass.arel_table[:paper_id].eq(Paper.arel_table[:id]))
      @joins.push klass
    end
  end

  add_simple_expression(keyword: 'STATUS IS NOT') do |status|
    Paper.arel_table[:publishing_state].not_eq(status)
  end

  add_simple_expression(keyword: 'STATUS IS') do |status|
    Paper.arel_table[:publishing_state].eq(status)
  end

  add_simple_expression(keyword: 'TYPE IS NOT') do |type|
    Paper.arel_table[:paper_type].not_eq(type)
  end

  add_simple_expression(keyword: 'TYPE IS') do |type|
    Paper.arel_table[:paper_type].eq(type)
  end

  add_expression(keywords: ['TITLE IS']) do |_|
    symbol('TITLE IS') >> /.*/.r.map do |title|
      Paper.arel_table[:title].eq(title)
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
    Paper.arel_table[:doi].eq(doi)
  end

  add_statement(/^\d+/.r.map { Paper.arel_table[:doi].eq(doi) })

  add_statement(/^.+/.r.map { Paper.arel_table[:title].eq(title) })

  def self.build(str)
    @joins = []
    @root = Paper.arel_table
    query = parse str
    @root.where(query)
  end
end
