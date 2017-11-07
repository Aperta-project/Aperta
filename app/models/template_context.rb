# Provides a base template context
class TemplateContext < Liquid::Drop
  # The list of scenarios we present to users to match up with letter templates.
  # A scenario presents the world of data that would be relevant to a letter template.
  # Not all TemplateContexts are scenarios. Some represent individual models from which scenarios are composed.
  def self.scenarios
    [
      PaperScenario,
      ReviewerReportScenario,
      InvitationScenario,
      TahiStandardTasks::PaperReviewerScenario,
      TahiStandardTasks::PreprintDecisionScenario,
      TahiStandardTasks::RegisterDecisionScenario,
      TechCheckScenario
    ]
  end

  # Defines a method that returns a type of TemplateContext.  Makes it easier to compose new contexts.
  # It also registers the method with MergeFieldBuilder so that the listing of merge fields spiders
  # into this context.
  #
  # type:     the specific return type, which is a subclass of TemplateContext
  #             e.g. type: :user means the return type is UserContext
  # source:   a chain of method calls to get the object that will be wrapped and returned
  #             e.g. [:object, :paper] means the source object is at self.object.paper
  # is_array: if true then the method returns an array instead of a single context
  #
  def self.context(context_name, options = {})
    subcontexts[context_name] = options
    return if respond_to?(context_name)

    default_source_chain = [:object, context_name]
    source_chain = options[:source] ? Array(options[:source]) : default_source_chain

    context_type = options[:type] || context_name
    context_class = "#{context_type}_context".camelize.constantize

    define_method context_name do
      context_instance_eval(context_name, source_chain, context_class, options[:is_array])
    end
  end

  def self.contexts(context_name, options = {})
    context(context_name, options.merge(is_array: true))
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :object
    end
  end

  def self.subcontexts
    @subcontexts ||= {}
  end

  def self.merge_fields
    @merge_fields ||= MergeFieldBuilder.merge_fields(self)
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
