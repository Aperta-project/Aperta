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
      'Decision' => RegisterDecisionScenario
    }.merge(feature_flagged_scenarios)
  end

  # temporary added for https://jira.plos.org/jira/browse/APERTA-11721
  # we should remove this once the preprint feature flag is removed
  # and move these scenarios back into ::scenarios
  def self.feature_flagged_scenarios
    scenarios = {}
    scenarios['Preprint Decision'] = PaperScenario if FeatureFlag[:PREPRINT]
    scenarios['Tech Check'] = TechCheckScenario if FeatureFlag[:CARD_CONFIGURATION]
    scenarios
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
  def self.subcontext(context_name, props = {})
    MergeField.register_subcontext(self, context_name, props)
    return if respond_to?(context_name)

    default_source_chain = [:object, context_name]
    source_chain = props[:source] ? Array(props[:source]) : default_source_chain
    context_class = class_for(props[:type] || context_name)

    define_method context_name do
      context_instance_eval(context_name, source_chain, context_class, props[:is_array])
    end
  end

  def self.subcontexts(context_name, props = {})
    subcontext(context_name, props.merge(is_array: true))
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :object
    end
  end

  def self.merge_fields
    @merge_fields ||= MergeField.list_for(self)
  end

  def self.class_for(context_type)
    "#{context_type}_context".camelize.constantize
  end

  def initialize(object)
    @object = object
  end

  private

  attr_reader :object

  def context_instance_eval(context_name, source_chain, context_class, is_array)
    cache = instance_variable_get("@#{context_name}")
    return cache if cache

    source = source_chain.reduce(self) { |obj, meth| obj.send(meth) }
    contextualized_source = if is_array
                              source.map { |source_item| context_class.new(source_item) }
                            else
                              context_class.new(source)
                            end

    instance_variable_set("@#{context_name}", contextualized_source)
  end
end
