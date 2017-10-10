class Snapshot::CardContentSerializer
  def initialize(card_content, owner, repetition = nil)
    @card_content = card_content
    @owner = owner
    @repetition = repetition
    @answer = fetch_answer
  end

  def as_json
    {
      name: @card_content.ident,
      type: 'question',
      content_type: @card_content.content_type,
      value: {
        repetition: @repetition.try(:id),
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
    if @card_content.content_type == "repeat"
      @card_content.repetitions.where(task: @owner, parent: @repetition).order(:lft).flat_map do |repetition|
        @card_content.children.map do |child|
          Snapshot::CardContentSerializer.new(child, @owner, repetition).as_json
        end
      end
    else
      @card_content.children.flat_map do |child|
        Snapshot::CardContentSerializer.new(child, @owner, @repetition).as_json
      end
    end
  end

  def serialized_attachments_json
    attachments = []
    attachments = @answer.attachments if @answer
    attachments.map do |attachment|
      Snapshot::AttachmentSerializer.new(attachment).as_json
    end
  end

  def fetch_answer
    @owner.answers
      .where(card_content: @card_content, repetition: @repetition)
      .first
  end
end
