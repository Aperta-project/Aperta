# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.scenarios
    {
      'Manuscript' => PaperScenario,
      'Reviewer Report' => ReviewerReportScenario,
      'Invitation' => InvitationScenario,
      'Paper Reviewer' => PaperReviewerScenario,
      'Preprint Decision' => PreprintDecisionScenario,
      'Decision' => RegisterDecisionScenario,
      'Tech Check' => TechCheckScenario
    }.merge(feature_flagged_scenarios)
  end

  # temporary added for https://jira.plos.org/jira/browse/APERTA-11721
  # we should remove this once the preprint feature flag is removed
  # and move these secnarios back into ::scenarios
  def self.feature_flagged_scenarios
    !FeatureFlag[:PREPRINT] ? {} : {'Preprint Decision' => PreprintDecisionScenario}
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
