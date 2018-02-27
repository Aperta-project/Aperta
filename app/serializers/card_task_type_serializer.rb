class CardTaskTypeSerializer < AuthzSerializer
  attributes :id,
             :display_name,
             :task_class

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
