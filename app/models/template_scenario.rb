# Provides a base template context
class TemplateScenario < TemplateContext
  def self.merge_fields(defs = merge_field_definitions)
    defs.map do |hash|
      hash[:children] = merge_fields(hash[:context].merge_field_definitions) if hash[:context]
      hash
    end
  end
end
