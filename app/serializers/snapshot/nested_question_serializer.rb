class Snapshot::NestedQuestionSerializer < Snapshot::BaseSerializer
  def initialize(nested_question, owner)
    @nested_question = nested_question
    @owner = owner
  end

  def as_json
    children = []
    @nested_question.children.all.each do |child|
      child_snapshotter = Snapshot::NestedQuestionSerializer.new child, @owner
      children << child_snapshotter.snapshot
    end

    answer = @owner.nested_question_answers
                    .select { |q| q.nested_question_id == @nested_question.id }
                    .sort { |a,b| a.id <=> b.id }
                    .first

    attachment = nil
    if answer
      attachment = QuestionAttachment.select { |qa| qa.question_id == answer.id }.first
    end

    {
      name: @nested_question.ident,
      type: "question",
      value: {
        title: @nested_question.text,
        answer_type: @nested_question.value_type,
        answer: answer ? answer.value : nil,
        attachment: Snapshot::QuestionAttachmentSerializer.new(attachment).snapshot,
        additional_data: answer ? answer.additional_data : nil
      },

      children: children
    }
  end
end
