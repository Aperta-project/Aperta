# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.scenarios
    [
      PaperScenario,
      ReviewerReportScenario,
      InvitationScenario,
      TahiStandardTasks::PaperReviewerScenario,
      TahiStandardTasks::PreprintDecisionScenario,
      TahiStandardTasks::RegisterDecisionScenario
    ]
  end

  def self.context(context_type, options = {})
    method_name = options[:as] || context_type
    return if respond_to?(method_name)

    context_class_name = "#{context_type}_context".camelize
    source_model = options[:source] || "object.#{method_name}"

    if options[:many]
      class_eval "def #{method_name}
        #{source_model}.map { |model| #{context_class_name}.new(model) }
      end"
    else
      class_eval "def #{method_name}
        #{context_class_name}.new(#{source_model})
      end"
    end
  end

  def self.merge_fields
    MergeFieldBuilder.merge_fields(self)
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :object
    end
  end

  def initialize(object)
    @object = object
  end

  private

  attr_reader :object
end
