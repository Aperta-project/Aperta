class NestedQuestionSerializer < AuthzSerializer
  attributes :id, :parent_id, :text, :ident, :value_type, :owner, :position

  def owner
    { id: object.owner_id, type: object.owner_type }
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
