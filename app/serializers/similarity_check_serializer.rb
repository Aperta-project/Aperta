class SimilarityCheckSerializer < ActiveModel::Serializer
  attributes :id,
    :dismissed,
    :error_message,
    :versioned_text_id,
    :ithenticate_score,
    :state,
    :updated_at
end
