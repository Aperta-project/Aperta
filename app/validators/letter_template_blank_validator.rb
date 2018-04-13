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

class LetterTemplateBlankValidator
  class << self
    def blank_fields?(letter_template, context)
      !get_blank_fields(letter_template, context).empty?
    end

    def blank_fields(letter_template, context)
      get_blank_fields(letter_template, context).map(&:raw).map(&:strip)
    end

    private

    def get_blank_fields(letter_template, context)
      liquid_variables = get_liquid_variables(letter_template.root.nodelist).flatten
      liquid_variables.select { |node| blank_liquid_variable?(node.name.name, node.name.lookups, context) }
    end

    def blank_liquid_variable?(name, lookups, context)
      context = context.deep_symbolize_keys if context.is_a? Hash
      context[name.to_sym].blank? || lookups.any? { |lookup| context[name.to_sym][lookup.to_sym].blank? }
    end

    def get_liquid_variables(liquid_nodelist)
      vars = []
      liquid_nodelist.each do |node|
        vars << node if node.is_a? Liquid::Variable
        vars << get_liquid_variables(node.nodelist) if node.respond_to? :nodelist
      end
      vars
    end
  end
end

class BlankRenderFieldsError < StandardError; end
