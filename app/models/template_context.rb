# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.merge_fields
    []
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :@object
    end
  end

  def initialize(object)
    @object = object
  end

  def self.build_merge_fields
    merge_fields.map do |hash|
      hash[:children] = hash[:context].build_merge_fields if hash[:context]
      hash
    end
  end
end
