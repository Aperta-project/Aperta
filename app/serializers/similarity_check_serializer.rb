class SimilarityCheckSerializer < ActiveModel::Serializer
  attributes :id,
    :versioned_text_id,
    :score,
    :report_url,
    :state,
    :updated_at

  def report_url
    report_view_only_url if object.report_complete?
  end
end
