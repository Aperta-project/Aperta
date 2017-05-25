class SimilarityCheckSerializer < ActiveModel::Serializer
  attributes :id,
    :versioned_text_id,
    :ithenticate_score,
    :state,
    :updated_at
end
