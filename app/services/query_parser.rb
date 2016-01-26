##
# This defines our particular query language.
#
# ORDER MATTERS! Expressions earlier on the page will take
# precedence.
class QueryParser
  extend QueryLanguageParser
  extend Rsec::Helpers

  add_simple_expression(keyword: 'STATUS IS NOT') do |status|
    ParsedQuery.new(not_status: status)
  end

  add_simple_expression(keyword: 'STATUS IS') do |status|
    ParsedQuery.new(status: status)
  end

  add_simple_expression(keyword: 'TYPE IS NOT') do |type|
    ParsedQuery.new(not_type: type)
  end

  add_simple_expression(keyword: 'TYPE IS') do |type|
    ParsedQuery.new(type: type)
  end

  add_expression(keywords: ['TITLE IS']) do |_|
    symbol('TITLE IS') >> /.*/.r.map do |title|
      ParsedQuery.new(title: title)
    end
  end

  add_simple_expression(keyword: 'DECISION IS NOT') do |decision|
    ParsedQuery.new(not_decision: decision)
  end

  add_simple_expression(keyword: 'DECISION IS') do |decision|
    ParsedQuery.new(decision: decision)
  end

  add_simple_expression(keyword: 'DOI IS') do |doi|
    ParsedQuery.new(doi: doi)
  end

  add_statement(/^\d+/.r.map { |d| ParsedQuery.new(doi: d) })

  add_statement(/^.+/.r.map { |t| ParsedQuery.new(title: t) })
end
