class SimilarityCheckSerializer < ActiveModel::Serializer
  attributes :id,
    :dismissed,
    :error_message,
    :paper_version_id,
    :ithenticate_score,
    :state,
    :updated_at
end
