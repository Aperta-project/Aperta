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

  def self.context(method_name, options = {})
    return if respond_to?(method_name)

    context_type = options[:type] || method_name
    context_class = "#{context_type}_context".camelize
    source_object = options[:source] || "object.#{method_name}"
    method_definition = if options[:many]
                          "def #{method_name}
                            #{source_object}.map do |model|
                              #{context_class}.new(model)
                            end
                          end"
                        else
                          "def #{method_name}
                            #{context_class}.new(#{source_object})
                          end"
                        end

    class_eval method_definition
  end

  def self.contexts(method_name, options = {})
    context(method_name, options.merge(many: true))
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
