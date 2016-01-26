##
# This
module QueryLanguageParser
  extend ActiveSupport::Concern
  extend Rsec::Helpers

  def predicate_regex
    /.*?(?=#{@keywords.join('|')}|$)/
  end

  def expression
    predicate = predicate_regex.r.map(&:strip)
    parsers = @expressions.map { |s| s.call(predicate) }
    parsers.reduce(&:|)
  end

  def add_expression(keywords:, &block)
    @keywords ||= ['AND', 'OR', '\(', '\)']
    @expressions ||= []
    @keywords.concat keywords
    @expressions.push block
  end

  def add_simple_expression(keyword:, &block)
    add_expression(keywords: [:keyword]) do |predicate|
      (symbol(keyword) >> predicate).map(&block)
    end
  end

  def boolean_join(unit, keyword, method)
    unit.join(symbol(keyword)).map do |xs|
      xs.reject { |x| x == keyword }.reduce(method)
    end
  end

  def statement
    unit = expression | '('.r >> lazy { or_expr } << ')'
    and_expr = boolean_join(unit, 'AND', :&)
    or_expr = boolean_join(and_expr, 'OR', :|)
  end

  def add_statement(parser)
    @statements ||= []
    @statements.push parser
  end

  def parse(str)
    language = (statement | @statements.reduce(:|)).eof
    language.parse! str
  end
end
