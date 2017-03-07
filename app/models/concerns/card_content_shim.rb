# This module is intended to be mixed into ActiveModel::Serializer
# subclasses that are serializing their card content as 'nested_questions'
module CardContentShim
  extend ActiveSupport::Concern

  included do
    has_many :nested_questions,
             serializer: CardContentAsNestedQuestionSerializer,
             embed: :ids,
             include: true
    has_many :nested_question_answers,
             serializer: AnswerAsNestedQuestionAnswerSerializer,
             embed: :ids,
             include: true

    def nested_questions
      object.card.latest_content_without_root
    end

    def nested_question_answers
      object.answers
    end
  end
end
