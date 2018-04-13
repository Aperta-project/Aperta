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

# Provides a base template context
class TemplateContext < Liquid::Drop
  # Some TemplateContexts we want to present to letter template admins to choose when creating new letter templates.
  # We call these scenarios and map them by a friendly scenario name.
  # A scenario presents the world of data that would be relevant to a letter template.
  # Not all TemplateContexts are scenarios. Some represent individual models from which scenarios are composed.
  def self.scenarios
    {
      'Manuscript'        => PaperScenario,
      'Reviewer Report'   => ReviewerReportScenario,
      'Invitation'        => InvitationScenario,
      'Paper Reviewer'    => InvitationScenario,
      'Decision'          => RegisterDecisionScenario,
      'Preprint Decision' => PaperScenario,
      'Tech Check'        => TechCheckScenario
    }.except(*feature_inactive_scenarios)
  end

  # temporary added for https://jira.plos.org/jira/browse/APERTA-11721
  # we should remove this once the preprint feature flag is removed
  def self.feature_inactive_scenarios
    [].tap do |scenarios|
      scenarios << 'Preprint Decision' unless FeatureFlag[:PREPRINT]
      scenarios << 'Tech Check'        unless FeatureFlag[:CARD_CONFIGURATION]
    end
  end

  # Unless already defined, this defines a method which returns a TemplateContext.
  # Intended to support a scenario being defined as a composition of TemplateContexts.
  # This method also registers the subcontext with the MergeField listing service.
  #
  # type:     the specific return type, which is a subclass of TemplateContext
  #             e.g. type: :user means the return type is UserContext
  # source:   a chain of method calls to get the object that will be wrapped and returned
  #             e.g. [:object, :paper] means the source object is at self.object.paper
  # is_array: if true then the method returns an array instead of a single context
  #
  def self.subcontext(subcontext_name, **args)
    MergeField.register_subcontext(self, subcontext_name, **args)
    return if respond_to?(subcontext_name)

    options = {
      subcontext_class: class_for(args[:type] || subcontext_name),
      subcontext_source: Array(args[:source] || [:object, subcontext_name]),
      is_array: args[:is_array]
    }

    define_method subcontext_name do
      define_subcontext(subcontext_name, **options)
    end
  end

  def self.subcontexts(subcontext_name, **args)
    subcontext(subcontext_name, **args.merge(is_array: true))
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :object
    end
  end

  def self.wraps(klass = nil)
    @wrapped_type ||= klass if klass

    @wrapped_type
  end

  def self.merge_fields
    @merge_fields ||= MergeField.list_for(self)
  end

  def self.class_for(context_type)
    "#{context_type}_context".camelize.constantize
  end

  def initialize(object)
    expected_type =  self.class.instance_variable_get('@wrapped_type')
    if expected_type && !object.is_a?(expected_type)
      raise "#{self.class} expected to wrap a #{expected_type} but got a #{object.class}"
    end

    @object = object
  end

  private

  attr_reader :object

  def define_subcontext(subcontext_name, subcontext_class:, subcontext_source:, is_array:)
    cache = instance_variable_get("@#{subcontext_name}")
    return cache if cache

    source = subcontext_source.reduce(self) { |obj, meth| obj.send(meth) }
    wrappped_source = if is_array
                        source.map { |source_item| source_item.nil? ? nil : subcontext_class.new(source_item) }
                      elsif source.nil?
                        nil
                      else
                        subcontext_class.new(source)
                      end

    instance_variable_set("@#{subcontext_name}", wrappped_source)
  end
end
