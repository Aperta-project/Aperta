# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.scenarios
    [
      ReviewerReportScenario,
      TahiStandardTasks::PaperReviewerScenario,
      TahiStandardTasks::PreprintDecisionScenario,
      TahiStandardTasks::RegisterDecisionScenario
    ]
  end

  def self.merge_fields
    MergeFieldBuilder.new(self).merge_fields
  end

  def self.complex_merge_fields
    []
  end

  def self.blacklisted_merge_fields
    []
  end

  def self.whitelist(*args)
    args.each do |method|
      delegate method, to: :@object
    end
  end

  def initialize(object)
    @object = object
  end
end
