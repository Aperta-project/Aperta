class LetterTemplateBlankValidator
  class << self
    def blank_fields?(letter_template, context)
      liquid_variables = get_liquid_variables(letter_template.root.nodelist).flatten
      liquid_variables.any? { |node| blank_liquid_variable?(node.name.name, node.name.lookups, context) }
    end

    private

    def blank_liquid_variable?(name, lookups, context)
      if context.is_a? Hash
        blank_liquid_variable_in_hash?(name, lookups, context)
      elsif context.is_a? TemplateScenario
        blank_liquid_variable_in_scenario?(name, lookups, context)
      end
    end

    def get_liquid_variables(liquid_nodelist)
      vars = []
      liquid_nodelist.each do |node|
        vars << node if node.is_a? Liquid::Variable
        vars << get_liquid_variables(node.nodelist) if node.is_a?(Liquid::Block) || node.is_a?(Liquid::BlockBody)
      end
      vars
    end

    def blank_liquid_variable_in_hash?(name, lookups, context)
      context = context.with_indifferent_access
      context[name].blank? || (!lookups.empty? && lookups.any? { |lookup| context[name][lookup].blank? })
    end

    def blank_liquid_variable_in_scenario?(name, lookups, context)
      context.send(name).blank? || (!lookups.empty? && lookups.any? { |lookup| context.send(name).send(lookup).blank? })
    end
  end
end

class BlankRenderFieldsError; end
