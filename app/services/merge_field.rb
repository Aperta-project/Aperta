# Merge fields are the subset of a context's attributes
# that we want to publicly advertise to email template admins.
class MergeField
  # Gets the list of merge fields that we want to show to letter template admins.
  def self.list_for(context_class)
    fields  = context_class.public_instance_methods - TemplateContext.public_instance_methods
    fields -= unlisted_merge_fields[context_class]

    subcontext_definitions = @subcontexts_by_parent[context_class]
    fields -= subcontext_definitions.keys

    subcontexts = subcontext_definitions.map do |subcontext_name, props|
      subcontext_props = props.slice(:is_array)

      subcontext_type = props[:type] || subcontext_name
      subcontext_class = TemplateContext.class_for(subcontext_type)
      # recursively list subcontexts
      subcontext_props[:children] = list_for(subcontext_class)
      [subcontext_name, subcontext_props]
    end

    (fields + subcontexts).map { |field_name, props| { name: field_name }.merge(props || {}) }
  end

  # Unlisted fields are excluded from the list
  def self.unlisted_merge_fields
    @unlisted_merge_fields ||= Hash.new { [] }.tap do |hash|
      hash[PaperContext] = [:url_for, :url_helpers]
      hash[ReviewerReportContext] = ActionView::Helpers::SanitizeHelper.public_instance_methods
    end
  end

  def self.register_subcontext(parent_context, subcontext_name, props)
    @subcontexts_by_parent ||= Hash.new { {} }
    subs = @subcontexts_by_parent[parent_context] || {}
    subs[subcontext_name] = props
    @subcontexts_by_parent[parent_context] = subs
  end
end
