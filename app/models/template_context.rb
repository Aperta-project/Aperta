# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.scenarios
    [
      PaperScenario,
      ReviewerReportScenario,
      InvitationScenario,
      TahiStandardTasks::PaperReviewerScenario,
      TahiStandardTasks::RegisterDecisionScenario,
      TechCheckScenario
    ] + feature_flagged_scenarios
  end

  # temporary added for https://jira.plos.org/jira/browse/APERTA-11721
  # we should remove this once the preprint feature flag is removed
  # and move these secnarios back into ::scenarios
  def self.feature_flagged_scenarios
    !FeatureFlag[:PREPRINT] ? [] : [TahiStandardTasks::PreprintDecisionScenario]
  end

  def self.merge_fields
    MergeFieldBuilder.merge_fields(self)
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
