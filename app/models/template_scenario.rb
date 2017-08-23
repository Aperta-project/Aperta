# Provides a base template context
class TemplateScenario < TemplateContext
  def self.merge_fields(defs = merge_field_definitions)
    defs.map do |hash|
      if hash[:context]
        hash[:children] = merge_fields(hash[:context].merge_field_definitions)
        hash.delete(:context)
      end
      hash
    end
  end
end