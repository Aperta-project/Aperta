class QuestionAttachmentSerializer < AuthzSerializer
  include ReadySerializable

  attributes :id,
             :title,
             :caption,
             :status,
             :filename,
             :src

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
