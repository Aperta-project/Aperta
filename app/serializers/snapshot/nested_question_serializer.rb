class Snapshot::NestedQuestionSerializer < Snapshot::BaseSerializer
  def initialize(nested_question, owner)
    @nested_question = nested_question
    @owner = owner
    @answer = fetch_answer
  end

  def as_json
    {
      name: @nested_question.ident,
      type: "question",
      value: {
        title: @nested_question.text,
        answer_type: @nested_question.value_type,
        answer: @answer.try(:value),
        attachment: serialized_attachment_json
      },
      children: serialized_children_json
    }
  end

  private

  def serialized_children_json
    @nested_question.children.map do |child|
      Snapshot::NestedQuestionSerializer.new(child, @owner).as_json
    end
  end

  def serialized_attachment_json
    if @answer
      attachment = QuestionAttachment.where(question: @answer).first
      Snapshot::QuestionAttachmentSerializer.new(attachment).as_json
    end
  end

  def fetch_answer
    @owner.nested_question_answers.where(
      nested_question_id: @nested_question.id
    ).first
  end
end
