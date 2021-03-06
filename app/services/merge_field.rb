# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Merge fields are the subset of a context's attributes
# that we want to publicly advertise to email template admins.
class MergeField
  # Gets the list of merge fields that we want to show to letter template admins.
  def self.list_for(context_class)
    fields = context_class.public_instance_methods - TemplateContext.public_instance_methods
    fields = Hash[fields.map { |field_name| [field_name, {}] }]

    subcontext_definitions = @subcontexts_by_parent[context_class]
    if subcontext_definitions
      subcontexts = {}
      subcontext_definitions.each do |subcontext_name, props|
        subcontext_type = props[:type] || subcontext_name
        subcontext_class = TemplateContext.class_for(subcontext_type)
        # recursively list subcontexts
        subcontext_props = { children: list_for(subcontext_class) }
        subcontext_props.merge!(props.slice(:is_array))
        subcontexts[subcontext_name] = subcontext_props
      end
      fields.merge!(subcontexts)
    end

    unlisted[context_class].each { |unlisted_field| fields.delete(unlisted_field) }
    fields.map { |field_name, props| { name: field_name }.merge(props) }
  end

  # Unlisted fields are excluded from the list
  def self.unlisted
    @unlisted ||= Hash.new { [] }.tap do |hash|
      hash[PaperContext] = [:url_for, :url_helpers, :preprint_opted_in, :preprint_opted_out]
      hash[ReviewerReportContext] = ActionView::Helpers::SanitizeHelper.public_instance_methods
      hash[UserContext] = [:title]
    end
  end

  def self.register_subcontext(parent_context, subcontext_name, props)
    @subcontexts_by_parent ||= {}
    @subcontexts_by_parent[parent_context] ||= {}
    @subcontexts_by_parent[parent_context][subcontext_name] = props
  end

  def self.subcontexts_for(context_class)
    @subcontexts_by_parent[context_class] || {}
  end
end
