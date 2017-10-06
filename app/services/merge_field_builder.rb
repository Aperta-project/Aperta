class MergeFieldBuilder
  def initialize(context)
    @context = context
  end

  def merge_fields(defs = merge_field_definitions)
    defs.map do |hash|
      if hash[:context]
        hash[:children] = merge_fields(MergeFieldBuilder.new(hash[:context]).merge_field_definitions)
        hash.delete(:context)
      end
      hash
    end
  end

  def merge_field_definitions
    simple_merge_fields + complex_merge_fields
  end

  private

  def complex_merge_fields
    @context.complex_merge_fields
  end

  def simple_merge_fields
    field_names = @context.public_instance_methods - TemplateContext.public_instance_methods
    complex_merge_field_names = @context.complex_merge_fields.map { |h| h[:name] }
    simple_field_names = field_names - complex_merge_field_names - @context.blacklisted_merge_fields
    simple_field_names.map { |n| { name: n } }
  end
end
