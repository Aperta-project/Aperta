module TahiStandardTasks
  class RegisterDecisionScenario < PaperScenario
    def reviews
      @reviews ||= [].tap do |reviews|
        return [] unless manuscript_object.draft_decision
        reports = manuscript_object.draft_decision.reviewer_reports.submitted
        reports_with_num, reports_without_num = reports.partition { |r| r.task.reviewer_number }
        reports = reports_with_num.sort_by { |r| r.task.reviewer_number } + reports_without_num.sort_by(&:submitted_at)
        reports.each { |rr| reviews << ReviewerReportContext.new(rr) }
      end
    end
  end
end
