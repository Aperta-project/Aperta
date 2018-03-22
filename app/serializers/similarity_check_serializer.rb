class SimilarityCheckSerializer < AuthzSerializer
  attributes :id,
    :dismissed,
    :error_message,
    :versioned_text_id,
    :ithenticate_score,
    :state,
    :updated_at

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
