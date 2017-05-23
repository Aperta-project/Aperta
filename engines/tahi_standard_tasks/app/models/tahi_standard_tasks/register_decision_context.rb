module TahiStandardTasks
  # Provides a template context for RegisterDecisionTasks
  class RegisterDecisionContext < Liquid::Drop
    attr_accessor :manuscript, :journal, :reviews

    def initialize(paper)
      @journal = JournalContext.new(paper.journal)
      @manuscript = PaperContext.new(paper)
      if paper.draft_decision
        @reviews = paper.draft_decision.reviewer_reports.map do |rr|
          ReviewerReportContext.new(rr)
        end
      end
    end
  end
end
