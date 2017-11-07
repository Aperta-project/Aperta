class PaperScenario < TemplateContext
  def manuscript
    @manuscript ||= PaperContext.new(manuscript_object)
  end

  def journal
    @journal ||= JournalContext.new(manuscript_object.journal)
  end

  private

  def manuscript_object
    @object
  end
end
