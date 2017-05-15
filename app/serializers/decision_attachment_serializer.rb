# Serializes DecisionAttachments. This is so we can help Ember associate an
# attachment with a decision, and avoid making a second HTTP request
class DecisionAttachmentSerializer < AttachmentSerializer
  has_one :decision, embed: :id
end
