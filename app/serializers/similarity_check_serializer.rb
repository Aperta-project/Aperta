class SimilarityCheckSerializer < ActiveModel::Serializer
  attributes :id,
    :versioned_text_id,
    :score,
    :state,
    :updated_at
end
