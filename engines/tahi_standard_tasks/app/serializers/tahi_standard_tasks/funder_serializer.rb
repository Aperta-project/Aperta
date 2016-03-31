module TahiStandardTasks
  class FunderSerializer < ActiveModel::Serializer
    attributes :additional_comments, :id, :name, :grant_number, :website

    has_one :task, embed: :ids
    has_many :authors, embed: :ids, include: true
    has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
    has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true
  end
end
