##
# A ParsedQuery is a very, very simple AST for queries in Aperta's query
# language.
class ParsedQuery
  ##
  # Values is a hash; each key:"value" pair represents an ANDed
  # query parameter; the only special key is :not, which is itself a
  # key:"value" hash but of negated arguments.
  attr_reader :values

  def initialize(options)
    @values = options
  end

  def ==(other)
    return false unless other.is_a?(ParsedQuery)
    @values == other.values
  end

  def &(other)
    o_values = other.values

    if values.is_a?(Array)
      ParsedQuery.new(values.map { |q| q & other })
    elsif o_values.is_a?(Array)
      ParsedQuery.new(o_values.map { |q| q & self })
    else
      ParsedQuery.new(values.merge o_values)
    end
  end

  def |(other)
    parts = Array.wrap(other.values) + Array.wrap(values)
    ParsedQuery.new(parts.map { |m| ParsedQuery.new(m) })
  end

  def build(x)
    if values.is_a?(Array)
      values.map { |q| q.build x }.join(' UNION? ')
    else
      'x' + (values.each_key.map do |key|
        send key, x
      end).join('')
    end
  end

  def status(_)
    ".where(publishing_state: #{values[:status]})"
  end

  def type(_)
    ".where(paper_type: #{values[:type]})"
  end
end
