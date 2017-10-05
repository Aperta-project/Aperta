class PaperScenario < TemplateScenario
  # base scenario for paper emails
  def self.complex_merge_fields
    [{ name: :journal, context: JournalContext },
     { name: :manuscript, context: PaperContext }]
  end

  def journal
    @journal ||= JournalContext.new(paper.journal)
  end

  def manuscript
    @manuscript ||= PaperContext.new(paper)
  end

  private

  def paper
    @object
  end
end
