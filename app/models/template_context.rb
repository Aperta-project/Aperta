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
    }
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
