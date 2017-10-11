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
