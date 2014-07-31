class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :ident, :question, :answer, :additional_data, :task_id
  has_one :question_attachment, embed: :id, include: true
end
