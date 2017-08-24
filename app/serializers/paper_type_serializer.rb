# This serializes an author-safe version of manuscipt manager templates
class PaperTypeSerializer < ActiveModel::Serializer
  attributes :id,
    :paper_type,
    :is_preprint_eligible
end
