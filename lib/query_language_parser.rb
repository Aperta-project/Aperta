# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

##
# This is a superclass of query parsers; it handles parsing AND, OR,
# and parentheses, and has some helpful class methods like
# 'add_expression' and 'add simple expression'.
#
class QueryLanguageParser
  extend ActiveSupport::Concern
  include Rsec::Helpers

  class << self
    attr_reader :keywords, :expressions, :statements

    def add_expression(keywords:, &block)
      # block, here, is a parser factory; it expects a single argument
      # (predicate, a parser that parses anything that's not a
      # keyword) and it returns a parser. @expressions is an array of
      # these parser factories.
      @keywords ||= ['AND', 'OR', /(?<!\\)(\(|\))/] # disallow escaped parens
      @expressions ||= []
      @keywords.concat keywords
      @expressions.push block
    end

    def add_no_args_expression(keyword, &block)
      add_expression(keywords: [keyword]) do |_|
        symbol(keyword).map do
          call_block_with_parsed_strings(block, [])
        end
      end
    end

    def add_simple_expression(keyword, &block)
      add_expression(keywords: [keyword]) do |predicate|
        (symbol(keyword) >> predicate).map do |parsed_string|
          call_block_with_parsed_strings(block, [parsed_string])
        end
      end
    end

    def add_two_part_expression(keyword, argument, &block)
      add_expression(keywords: [keyword, argument]) do |predicate|
        seq(symbol(keyword) >> predicate,
            symbol(argument) >> predicate).map do |seq|
          call_block_with_parsed_strings(block, [seq[0].strip, seq[1].strip])
        end
      end
    end

    def add_statement(parser, &block)
      @statements ||= []
      @statements.push(parser: parser, block: block)
    end
  end

  def parse(str)
    language = (expression_statement | statements.reduce(:|)).eof
    language.parse! str.strip.gsub(/\s+/, " ")
  end

  private

  def call_block_with_parsed_strings(block, parsed_strings)
    # Instance exec because these blocks are defined at the class
    # level (using, e.g., add_simple_expression), but they must be run
    # at the instance level.
    instance_exec(*parsed_strings, &block)
  end

  def boolean_join(unit, keyword, method)
    unit.join(symbol(keyword)).map do |xs|
      xs.reject { |x| x == keyword }.reduce(method)
    end
  end

  def statements
    self.class.statements.map do |statement|
      statement[:parser].map do |parsed_string|
        call_block_with_parsed_strings(statement[:block], [parsed_string])
      end
    end
  end

  def expression
    predicate = predicate_regex.r.map(&:strip)
    parsers = self.class.expressions.map do |parser_factory|
      # A parser factory is a block that takes a predicate parser and
      # returns an expression parser.
      instance_exec(predicate, &parser_factory)
    end
    parsers.reduce(&:|)
  end

  def expression_statement
    unit = expression | '('.r >> lazy { or_expr } << ')'
    and_expr = boolean_join(unit, 'AND', :and)
    or_expr = boolean_join(and_expr, 'OR', :or)
  end

  def predicate_regex
    /.*?(?=#{self.class.keywords.join('|')}|$)/
  end
end
