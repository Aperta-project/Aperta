class RepetitionSerializer < AuthzSerializer
  attributes :id,
    :card_content_id,
    :task_id,
    :parent_id,
    :position

  has_one :card_content, embed: :id
  has_one :task, embed: :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
