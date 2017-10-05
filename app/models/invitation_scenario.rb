class InvitationScenario < PaperScenario
  # base sceanario for invitation emails
  def self.complex_merge_fields
    [{ name: :invitation, context: InvitationContext },
     { name: :journal, context: JournalContext },
     { name: :manuscript, context: PaperContext }]
  end

  def invitation
    @invitation ||= InvitationContext.new(@object)
  end

  private

  def paper
    @object.paper
  end
end
