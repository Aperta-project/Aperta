# Snapshot serializer for Card Content (and Answer)
class Snapshot::CardContentSerializer
  def initialize(card_content, owner)
    @card_content = card_content
    @owner = owner
    @answer = fetch_answer
  end

  def as_json
    {
      name: @card_content.ident,
      type: 'question',
      value: {
        id: @card_content.id,
        title: @card_content.text,
        answer_type: @card_content.value_type,
        answer: @answer.try(:value),
        attachments: serialized_attachments_json
      },
      children: serialized_children_json
    }
  end

  private

  def serialized_children_json
    @card_content.children.map do |child|
      Snapshot::CardContentSerializer.new(child, @owner).as_json
    end
  end

  def serialized_attachments_json
    return [] unless @answer
    @answer.attachments.map do |attachment|
      Snapshot::AttachmentSerializer.new(attachment).as_json
    end
  end

  def fetch_answer
    @owner.answers.find_by(card_content: @card_content)
  end
end
