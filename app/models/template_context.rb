# Provides a base template context
class TemplateContext < Liquid::Drop
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

  def self.context(context_name, options = {})
    subcontexts[context_name] = options
    return if respond_to?(context_name)

    source_chain = options[:source] || [:object, context_name]
    context_type = options[:type] || context_name
    context_class = "#{context_type}_context".camelize.constantize

    define_method context_name do
      context_instance_eval(context_name, source_chain, context_class, options[:many])
    end
  end

  def self.contexts(context_name, options = {})
    context(context_name, options.merge(many: true))
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
