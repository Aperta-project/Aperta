# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.merge_field_definitions
    simple_merge_fields.map { |n| { name: n } } + complex_merge_fields
  end

  def self.complex_merge_fields
    []
  end

  def self.blacklisted_merge_fields
    []
  end

  def self.simple_merge_fields
    field_names = public_instance_methods - TemplateContext.public_instance_methods
    complex_merge_field_names = complex_merge_fields.map { |h| h[:name] }
    field_names - complex_merge_field_names - blacklisted_merge_fields
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :@object
    end
  end

  def initialize(object)
    @object = object
  end
end
