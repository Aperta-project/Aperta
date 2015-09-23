class NestedQuestionSerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :text, :ident, :value_type, :owners
  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true

  def owners
    [{id: 96, type: "TahiStandardTasks::ReviewerRecommendation"},
     {id: 103, type: "TahiStandardTasks::ReviewerRecommendation"},
     {id: 104, type: "TahiStandardTasks::ReviewerRecommendation"}]
    #{ id: object.owner_id, type: object.owner_type }
  end

  def nested_questions
    object.children
  end
end
