class AuthorSerializer < ActiveModel::Serializer
  attributes :affiliation, :corresponding, :deceased, :department,
             :email, :first_name, :id, :last_name, :middle_initial, :paper_id,
             :position, :secondary_affiliation, :title

  has_one :authors_task, embed: :id
  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
  has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true
end
