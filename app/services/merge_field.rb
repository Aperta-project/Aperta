class MergeField
  # Lists fields that we want to suggest to letter template admins.
  def self.list_for(context)
    field_names  = context.public_instance_methods - TemplateContext.public_instance_methods
    field_names -= unlisted_merge_fields[context]

    subcontexts  = context.subcontexts.map { |field_name, options| expand_context(field_name, options) }
    field_names -= context.subcontexts.keys

    field_names.map { |field_name| { name: field_name } } +
      subcontexts.map { |field_name, options| { name: field_name }.merge(options) }
  end

  # Recursively get all merge fields for a context
  def self.expand_context(field_name, options)
    context_type = options[:type] || field_name
    context_class = "#{context_type}_context".camelize.constantize
    expansion_options = options.slice(:is_array)
    expansion_options[:children] = list_for(context_class)

    [field_name, expansion_options]
  end

  # Unlisted fields are excluded from the list
  def self.unlisted_merge_fields
    @unlisted_merge_fields ||= Hash.new { [] }.tap do |hash|
      hash[PaperContext] = [:url_for, :url_helpers]
      hash[ReviewerReportContext] = ActionView::Helpers::SanitizeHelper.public_instance_methods
    end
  end
end
