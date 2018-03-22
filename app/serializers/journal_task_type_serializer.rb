class JournalTaskTypeSerializer < AuthzSerializer
  attributes :id, :title, :kind, :role_hint, :system_generated, :journal_id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
