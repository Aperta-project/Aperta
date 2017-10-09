class MergeFieldBuilder
  def self.merge_fields(context)
    field_names  = context.public_instance_methods - TemplateContext.public_instance_methods
    field_names -= context.blacklisted_merge_fields
    field_names -= context.complex_merge_fields.map { |mf| mf[:name] }

    basic_fields   = field_names.map { |field_name| { name: field_name } }
    complex_fields = context.complex_merge_fields.map { |mf| expand_context(mf) }

    basic_fields + complex_fields
  end

  def self.expand_context(merge_field)
    context = merge_field.delete(:context)
    merge_field[:children] = merge_fields(context) if context
    merge_field
  end
end
