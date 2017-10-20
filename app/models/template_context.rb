# Provides a base template context
class TemplateContext < Liquid::Drop
  def self.scenarios
    {
      'Manuscript'         => PaperScenario,
      'Review'             => ReviewerReportScenario,
      'Invitation'         => InvitationScenario,
      'Decision'           => TahiStandardTasks::RegisterDecisionScenario,
      'Prepreint Decision' => TahiStandardTasks::PreprintDecisionScenario,
      'Paper Reviewer'     => TahiStandardTasks::PaperReviewerScenario
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
